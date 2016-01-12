/**
 * Copyright (c) 2015 Open-RnD Sp. z o.o.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

using Soup;
using GUPnP;

private const string DEVICE_FILE = "device.xml";
private const string DEVICE_DIR = ".";

public class Main {

	// prased redirect URL
	private static Soup.URI parsed_uri = null;
	// presentation URI we hook up to
	private static string presentation_uri = null;
	// Context manager
	private static GUPnP.ContextManager ctx_mgr = null;

	// Command line options
	private static bool log_debug = false;
	private static string redirect_target = null;
	private static string dev_xml = null;

	private static const GLib.OptionEntry[] options = {
		{"debug", 'd', 0, OptionArg.NONE, ref log_debug, "Show debug output", null},
		{"redirect-target", 't', 0, OptionArg.STRING,
		 ref redirect_target,
		 "Presentation URL HTTP redirect target, ex. http://0.0.0.0", null},
		{"device-xml", 'x', 0, OptionArg.FILENAME, ref dev_xml,
		 "Path to device XML", null},
		{null}
	};

    /**
	 * config_cb:
	 *
	 * Callback for presentation URL handling
	 */
	private static void config_cb(Soup.Server server, Soup.Message msg,
								  string path) {

		message("handle config request");

		assert(parsed_uri != null);
		string target;

		if (parsed_uri.host == "0.0.0.0") {
			var address = msg.get_address().get_name();

			debug("setting target host address to %s", address);

			var uri = parsed_uri.copy();
			uri.set_host(address);
			target = uri.to_string(false);
		} else {
			target = parsed_uri.to_string(false);
		}

		debug("redirecting to: %s", target);

		msg.set_redirect(Soup.Status.FOUND, target);
	}

	private static void setup_for_context(Context ctx) {

		assert(presentation_uri != null);

		var dev = UPnPDevice.new_device(ctx, dev_xml);

		if (dev == null) {
			error("failed to setup new device");
		}

		ctx.add_server_handler(false, presentation_uri,
							   (server, msg, path, query, client) => {
								   message("got presentation URL request");
								   config_cb(server, msg, path);
							   });

		debug("set device available");
		dev.set_available(true);

		debug("add to context manager");
		ctx_mgr.manage_root_device(dev);
	}

	public static void on_context_available(Context ctx) {
		debug("context available: %s %u", ctx.host_ip, ctx.port);

		setup_for_context(ctx);
	}

	public static void on_context_unavailable(Context ctx) {
		debug("context unavailable: %s %u", ctx.host_ip, ctx.port);

	}

	private static bool parse_redirect_target(string redirect_target) {
		var uri = new Soup.URI(redirect_target);

		if (uri == null)
			return false;

		parsed_uri = uri;
		debug("parsed URI: %s", parsed_uri.to_string(false));

		return true;
	}

	private static bool setup_presentation_handler(string device_xml_path) {
		string pres_url = UPnPDevice.get_presentation_url_from_desc(device_xml_path);

		if (pres_url == null)
			return false;

		presentation_uri = pres_url;

		debug("presentation URL: %s", presentation_uri);
		return true;
	}

	public static int main(string[] args)
		{
			try {
				var opt_context = new OptionContext();
				opt_context.set_description("""Ros3D UPnP presentation URL helper.

Redirect target shall contain a valid URI that the incoming request
will be redirected to, example: http://192.168.1.1/. The special host
address 0.0.0.0 indicates that the target address of the incoming
address is to be used as the host. For instance, given a redirect
target http://0.0.0.0:1213/config, an incoming presentation URL
request to the address mydevice.local will be redirected to
http://mydevice.local:1213/config.
""");
				 opt_context.set_help_enabled(true);
				 opt_context.add_main_entries(options, null);
				 opt_context.parse(ref args);
			} catch (OptionError e) {
				stdout.printf("error: %s\n", e.message);
				stdout.printf("Run '%s --help' to see a full list of available command line options.\n",
							  args[0]);
				return 1;
			}

			if (log_debug == true)
				Environment.set_variable("G_MESSAGES_DEBUG", "all", false);

			if (redirect_target == null || dev_xml == null) {
				warning("Missing command line arguments, see --help");
				return 11;
			}

			debug("redirect target: %s", redirect_target);
			debug("device xml: %s", dev_xml);

			if (parse_redirect_target(redirect_target) == false) {
				warning("Incorrect redirect target URI");
				return -1;
			}

			if (setup_presentation_handler(dev_xml) == false) {
				return -1;
			}

			ctx_mgr = GUPnP.ContextManager.create(0);

			ctx_mgr.context_available.connect((ctx) => {
					on_context_available(ctx);
				});
			ctx_mgr.context_unavailable.connect((ctx) => {
					on_context_unavailable(ctx);
				});

			var loop = new MainLoop();

			message("loop run()...");
			loop.run();
			message("loop done..");
			return 0;
		}
}