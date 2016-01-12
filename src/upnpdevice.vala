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

using GUPnP;
using Soup;
using Xml;

namespace UPnPDevice {

    /**
	 * get_presentation_url_from_desc:
	 * @file: path to device XML file
	 *
	 * Parse device XML file and locate presentation URL.
	 */
	public static string get_presentation_url_from_desc(string device_path) {
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

	public static GUPnP.RootDevice? new_device(GUPnP.Context ctx, string device_path) {

		assert(ctx != null);
		assert(device_path != null);

		var dev = new GUPnP.RootDevice(ctx,
									   Path.get_basename(device_path),
									   Path.get_dirname(device_path));
		if (dev == null) {
			error("failed to create root device for %s", device_path);
		}
		return dev;
	}



}