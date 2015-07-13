using Soup;
using GUPnP;

private const string DEVICE_FILE = "device.xml";
private const string DEVICE_DIR = ".";

public class Main {

	// prased redirect URL
	private static Soup.URI parsed_uri = null;
	// current GUPnP context
	private static GUPnP.Context ctx = null;

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

	private static bool parse_redirect_target(string redirect_target) {
		var uri = new Soup.URI(redirect_target);

		if (uri == null)
			return false;

		parsed_uri = uri;
		debug("parsed URI: %s", parsed_uri.to_string(false));

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

			try {
				debug("create new UPnP context");
				ctx = new GUPnP.Context(null, null, 0);
			} catch (GLib.Error e) {
				error("failed to create context: %s", e.message);
			}

			var dev = UPnPDevice.new_for_device(ctx, dev_xml);

			if (dev == null) {
				return -1;
			}

			ctx.add_server_handler(false, dev.presentation_url,
								   (server, msg, path, query, client) => {
									   message("got presentation URL request");
									   config_cb(server, msg, path);
								   });

			dev.dev.set_available(true);

			message("location address: http://%s:%u", ctx.host_ip, ctx.port);
			var loop = new MainLoop();

			message("loop run()...");
			loop.run();
			message("loop done..");
			return 0;
		}
}