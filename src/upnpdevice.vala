using GUPnP;
using Soup;
using Xml;

public class UPnPDevice {

	// root device for this wrappper
	public GUPnP.RootDevice dev { get; private set; default = null; }

	public string presentation_url { get; private set; default = null; }

	private UPnPDevice() {

	}

    /**
	 * find_presentation_url:
	 * @file: path to device XML file
	 *
	 * Parse device XML file and locate presentation URL.
	 */
	private static string find_presentation_url(string device_path) {
		// ugly libxml bindings

		Xml.Doc *doc = Xml.Parser.parse_file(device_path);
		if (doc == null) {
			error("failed to parse %s", device_path);
		}

		Xml.XPath.Context ctx = new Xml.XPath.Context(doc);
		// register namespace
		ctx.register_ns("ud", "urn:schemas-upnp-org:device-1-0");

		Xml.XPath.Object *res;
		res = ctx.eval_expression("/ud:root/ud:device/ud:presentationURL");

		// expecting a nodeset with single node
		if (res == null || res->type != Xml.XPath.ObjectType.NODESET
			|| res->nodesetval->length() != 1) {
			message("res type: %d", res->type);
			error("failed to find presentation URL");
		}

		Xml.Node *node = res->nodesetval->item(0);
		// node content is the presentation URL
		debug("node content: %s", node->get_content());

		string url = node->get_content();

		delete res;
		delete doc;

		return url;
	}

	public static UPnPDevice? new_for_device(GUPnP.Context ctx, string device_path) {

		assert(ctx != null);
		assert(device_path != null);

		var dev = new UPnPDevice();

		var url = find_presentation_url(device_path);
		if (url == null) {
			error("no presentation URL");
		}

		message("found presentation URL: %s", url);
		dev.presentation_url = url;

 		dev.dev = new GUPnP.RootDevice(ctx,
									   Path.get_basename(device_path),
									   Path.get_dirname(device_path));
		if (dev.dev == null) {
			error("failed to create root device for %s", device_path);
		}
		return dev;
	}



}