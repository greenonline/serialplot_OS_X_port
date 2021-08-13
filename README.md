# serialplot_OS_X_port
OS X port of hyOzd / serialplot

An OS X port of [SerialPlot - Realtime Plotting Software](https://hackaday.io/project/5334-serialplot-realtime-plotting-software)

OS X binaries and scripts relating to [hyOzd](https://github.com/hyOzd)/[**serialplot**](https://github.com/hyOzd/serialplot)

The application works on OS X 10.13.6 (High Sierra). It is untested on other OS X verisons.

Full documentation on the OS X build is on [Porting serialplot to OS X](https://gr33nonline.wordpress.com/2021/08/03/porting-serialplot-to-os-x/).  A shorter HOWTO is coming.

Built on:
 - OS X 10.13.6
 - Using QtCreator 4.5
 - Using Qt5
 - Using Qwt.6.2.0
 - Qt5 and Qwt (6.2.0) frameworks are bundled into the application bundle using the script, `otool_serialplot_qwt_cocoa.sh`


### Running the script `otool_serialplot_qwt_cocoa.sh`

**Important Note**: Only run this script when *building* the application - it is not for general use.

 - Run from the directory containing `serialplot.app`,
   - unless you change `app_bundle_path` to the full path, i.e. `/Users/username/qtcodeworkspace/serialplot`
 - It expects the application bundle to be called `serialplot`
   - unless you change `application` to a different name
 - Create the `serialplot.app/Contents/Frameworks` directory manually
   - if you plan to copy `qwt.framework` over manually first to `serialplot.app/Contents/Frameworks` (i.e. the following step)
   - The directory will be created automatically (by the script) if it does not exist
 - Copy `qwt.framework` over manually first to `serialplot.app/Contents/Frameworks`,
   - unless you set `do_qwt_copy` to `true`.
   - You may need to change `path_qwt` if the `qwt` source directory doesn't share the same parent folder as the directory containing the application bundle
 - Copy the Qt frameworks over manually first to `serialplot.app/Contents/Frameworks`,
   - unless you set `do_copy` to `true`.
 - Leave `do_id` as `false`
   - Setting the `-id` causes the application to crash (reason unknown)
 - Leave `do_qwt` as `true`
   - This sets the qwt.framework to point to the bundled Qt frameworks
 - Leave `do_cocoa` as `true`
   - This copies over `libqcocoa.dylib` - if `do_copy` is `true`
   - This sets the Qt frameworks to point to `libqcocoa.dylib`
 - `do_core` does nothing (yet)
   - It was meant for a test to leave `QtCore.framework` unbundled - to prevent the crash caused by the unbundled `libqcocoa.dylib`
   - Unimplemented


[![][1]][1]


  [1]: https://gr33nonline.files.wordpress.com/2021/08/serialplot-ported-screenshot.png
