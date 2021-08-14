#!/bin/sh

# Name: otool_serialplot_qwt_cocoa.sh
#
# - Run from the directory containing `serialplot.app`,
#   - unless you change `app_bundle_path` to the full path, i.e. `/Users/username/qtcodeworkspace/serialplot`
# - It expects the application bundle to be called `serialplot`
#   - unless you change `application` to a different name
# - Create the `serialplot.app/Contents/Frameworks` directory manually
#   - if you plan to copy `qwt.framework` over manually first to `serialplot.app/Contents/Frameworks` (i.e. the following step)
#   - The directory will be created automatically (by the script) if it does not exist
# - Copy `qwt.framework` over manually first to `serialplot.app/Contents/Frameworks`, and run `install_name_tool -change qwt.framework/Versions/6/qwt @rpath/qwt.framework/Versions/6/qwt serialplot.app/Contents/MacOS/serialplot`
#   - unless you set `do_qwt_copy` to `true`.
#   - You may need to change `path_qwt` if the `qwt` source directory doesn't share the same parent folder as the directory containing the application bundle
# - Copy the Qt frameworks over manually first to `serialplot.app/Contents/Frameworks`,
#   - unless you set `do_copy` to `true`.
# - Leave `do_id` as `false`
#   - Setting the `-id` causes the application to crash (reason unknown)
# - Leave `do_qwt` as `true`
#   - This sets `qwt.framework` to point to the bundled Qt frameworks
# - Leave `do_cocoa` as `true`
#   - This copies over `libqcocoa.dylib` - if `do_copy` is `true`
#   - This sets the Qt frameworks to point to `libqcocoa.dylib`
# - `do_core` does nothing (yet)
#   - It was meant for a test to leave `QtCore.framework` unbundled - to prevent the crash caused by the unbundled `libqcocoa.dylib`
#   - Unimplemented

# Paths (change these)

application='serialplot'
app_bundle_path='.'
qt_brew_path='/usr/local/Cellar/qt@5/5.15.2'
lib_path_opt='/usr/local/opt/qt@5/lib'

# Paths (try not to change these)

app_name="${app_bundle_path}/${application}"
lib_path_brew="${qt_brew_path}/lib"
path_cocoa="${qt_brew_path}/plugins/platforms"
app_binary_path="${app_name}.app/Contents/MacOS/${app_name}"
app_frame_path="${app_name}.app/Contents/Frameworks"
plugplat='PlugIns/platforms'
app_plugin_path="${app_name}.app/Contents/${plugplat}"
path_qwt="${app_bundle_path}/../qwt/lib"

# Flags

do_copy="true" 
do_qwt="true" 
do_id="false"
do_cocoa="true"
do_qwt_copy="false"
do_core='true'

# Copy

if [ "X$do_copy" = "Xtrue" ]
then

  mkdir -p $app_frame_path

  cp -R ${lib_path_brew}/QtCore.framework $app_frame_path 
  cp -R ${lib_path_brew}/QtGui.framework $app_frame_path 
  cp -R ${lib_path_brew}/QtNetwork.framework $app_frame_path 
  cp -R ${lib_path_brew}/QtSerialPort.framework $app_frame_path 
  cp -R ${lib_path_brew}/QtSvg.framework $app_frame_path 
  cp -R ${lib_path_brew}/QtWidgets.framework $app_frame_path

  if [ "X$do_qwt" = "Xtrue" ]
  then
    cp -R ${lib_path_brew}/QtConcurrent.framework $app_frame_path 
    cp -R ${lib_path_brew}/QtPrintSupport.framework $app_frame_path 
    cp -R ${lib_path_brew}/QtOpenGL.framework $app_frame_path
  fi

  if [ "X$do_cocoa" = "Xtrue" ]
  then
    mkdir -p $app_plugin_path
    cp -R ${path_cocoa}/libqcocoa.dylib $app_plugin_path 
  fi

  if [ "X$do_qwt_copy" = "Xtrue" ]
  then
    cp -R ${path_qwt}/qwt.framework $app_frame_path 
  fi
fi

# Change

# Change app binary

install_name_tool -change ${lib_path_opt}/QtSvg.framework/Versions/5/QtSvg @rpath/QtSvg.framework/Versions/5/QtSvg $app_binary_path
install_name_tool -change ${lib_path_opt}/QtWidgets.framework/Versions/5/QtWidgets @rpath/QtWidgets.framework/Versions/5/QtWidgets $app_binary_path
install_name_tool -change ${lib_path_opt}/QtGui.framework/Versions/5/QtGui @rpath/QtGui.framework/Versions/5/QtGui $app_binary_path
install_name_tool -change ${lib_path_opt}/QtSerialPort.framework/Versions/5/QtSerialPort @rpath/QtSerialPort.framework/Versions/5/QtSerialPort $app_binary_path
install_name_tool -change ${lib_path_opt}/QtNetwork.framework/Versions/5/QtNetwork @rpath/QtNetwork.framework/Versions/5/QtNetwork $app_binary_path
install_name_tool -change ${lib_path_opt}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore $app_binary_path


# These three commands may not be required as the application binary does not call them directly, only via qwt
if [ "X$do_qwt" = "Xtrue" ]
#if [ "X$do_qwt" = "X666" ]  # Uncomment this line if you want to check if necessary or not - comment out previous line also
then
  install_name_tool -change ${lib_path_opt}/QtConcurrent.framework/Versions/5/QtConcurrent @rpath/QtConcurrent.framework/Versions/5/QtConcurrent $app_binary_path
  install_name_tool -change ${lib_path_opt}/QtPrintSupport.framework/Versions/5/QtPrintSupport @rpath/QtPrintSupport.framework/Versions/5/QtPrintSupport $app_binary_path
  install_name_tool -change ${lib_path_opt}/QtOpenGL.framework/Versions/5/QtOpenGL @rpath/QtOpenGL.framework/Versions/5/QtOpenGL $app_binary_path
fi

if [ "X$do_qwt_copy" = "Xtrue" ]
then
  install_name_tool -change qwt.framework/Versions/6/qwt @rpath/qwt.framework/Versions/6/qwt $app_binary_path
fi

# Change QtGui

chmod +w ${app_frame_path}/QtGui.framework/Versions/5/QtGui
install_name_tool -change ${lib_path_brew}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtGui.framework/Versions/5/QtGui
chmod -w ${app_frame_path}/QtGui.framework/Versions/5/QtGui

# Change QtSvg

chmod +w ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg
install_name_tool -change ${lib_path_brew}/QtWidgets.framework/Versions/5/QtWidgets @rpath/QtWidgets.framework/Versions/5/QtWidgets ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg 
install_name_tool -change ${lib_path_brew}/QtGui.framework/Versions/5/QtGui @rpath/QtGui.framework/Versions/5/QtGui ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg 
install_name_tool -change ${lib_path_brew}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg
chmod -w ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg

# Change QtWidgets

chmod +w ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets
install_name_tool -change ${lib_path_brew}/QtGui.framework/Versions/5/QtGui @rpath/QtGui.framework/Versions/5/QtGui ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets 
install_name_tool -change ${lib_path_brew}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets
chmod -w ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets

# Change QtSerialPort

chmod +w ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort
install_name_tool -change ${lib_path_brew}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort 
chmod -w ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort

# Change QtNetwork

chmod +w ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork
install_name_tool -change ${lib_path_brew}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork
chmod -w ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork

# Change qwt

if [ "X$do_qwt" = "Xtrue" ]
then
  chmod +w ${app_frame_path}/qwt.framework/Versions/6/qwt
  install_name_tool -change ${lib_path_opt}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/qwt.framework/Versions/6/qwt
  install_name_tool -change ${lib_path_opt}/QtGui.framework/Versions/5/QtGui @rpath/QtGui.framework/Versions/5/QtGui ${app_frame_path}/qwt.framework/Versions/6/qwt
  install_name_tool -change ${lib_path_opt}/QtSvg.framework/Versions/5/QtSvg @rpath/QtSvg.framework/Versions/5/QtSvg ${app_frame_path}/qwt.framework/Versions/6/qwt
  install_name_tool -change ${lib_path_opt}/QtWidgets.framework/Versions/5/QtWidgets @rpath/QtWidgets.framework/Versions/5/QtWidgets ${app_frame_path}/qwt.framework/Versions/6/qwt

  install_name_tool -change ${lib_path_opt}/QtOpenGL.framework/Versions/5/QtOpenGL @rpath/QtOpenGL.framework/Versions/5/QtOpenGL ${app_frame_path}/qwt.framework/Versions/6/qwt
  install_name_tool -change ${lib_path_opt}/QtConcurrent.framework/Versions/5/QtConcurrent @rpath/QtConcurrent.framework/Versions/5/QtConcurrent ${app_frame_path}/qwt.framework/Versions/6/qwt
  install_name_tool -change ${lib_path_opt}/QtPrintSupport.framework/Versions/5/QtPrintSupport @rpath/QtPrintSupport.framework/Versions/5/QtPrintSupport ${app_frame_path}/qwt.framework/Versions/6/qwt
  chmod -w ${app_frame_path}/qwt.framework/Versions/6/qwt
fi

# Change QtConcurrent

if [ "X$do_qwt" = "Xtrue" ]
then
  chmod +w ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
  install_name_tool -change ${lib_path_brew}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
  chmod -w ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
fi

# Change QtPrintSupport

if [ "X$do_qwt" = "Xtrue" ]
then
  chmod +w ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
  install_name_tool -change ${lib_path_brew}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
  install_name_tool -change ${lib_path_brew}/QtWidgets.framework/Versions/5/QtWidgets @rpath/QtWidgets.framework/Versions/5/QtWidgets ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport 
  install_name_tool -change ${lib_path_brew}/QtGui.framework/Versions/5/QtGui @rpath/QtGui.framework/Versions/5/QtGui ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport 
  chmod -w ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
fi

# Change QtOpenGL

if [ "X$do_qwt" = "Xtrue" ]
then
  chmod +w ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
  install_name_tool -change ${lib_path_brew}/QtCore.framework/Versions/5/QtCore @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
  install_name_tool -change ${lib_path_brew}/QtWidgets.framework/Versions/5/QtWidgets @rpath/QtWidgets.framework/Versions/5/QtWidgets ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
  install_name_tool -change ${lib_path_brew}/QtGui.framework/Versions/5/QtGui @rpath/QtGui.framework/Versions/5/QtGui ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
  chmod -w ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
fi

# Change id

if [ "X$do_id" = "Xtrue" ]
then

  chmod +w ${app_frame_path}/QtGui.framework/Versions/5/QtGui
  chmod +w ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg
  chmod +w ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets
  chmod +w ${app_frame_path}/QtCore.framework/Versions/5/QtCore
  chmod +w ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort
  chmod +w ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork
  install_name_tool -id @rpath/QtGui.framework/Versions/5/QtGui ${app_frame_path}/QtGui.framework/Versions/5/QtGui
  install_name_tool -id @rpath/QtSvg.framework/Versions/5/QtSvg ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg
  install_name_tool -id @rpath/QtCore.framework/Versions/5/QtCore ${app_frame_path}/QtCore.framework/Versions/5/QtCore
  install_name_tool -id @rpath/QtWidgets.framework/Versions/5/QtWidgets ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets
  install_name_tool -id @rpath/QtSerialPort.framework/Versions/5/QtSerialPort ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort
  install_name_tool -id @rpath/QtNetwork.framework/Versions/5/QtNetwork ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork
  chmod -w ${app_frame_path}/QtGui.framework/Versions/5/QtGui
  chmod -w ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg
  chmod -w ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets
  chmod -w ${app_frame_path}/QtCore.framework/Versions/5/QtCore
  chmod -w ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort
  chmod -w ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork

  if [ "X$do_qwt" = "Xtrue" ]
  then
    chmod +w ${app_frame_path}/qwt.framework/Versions/6/qwt
    chmod +w ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
    chmod +w ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
    chmod +w ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
    install_name_tool -id @rpath/qwt.framework/Versions/6/qwt ${app_frame_path}/qwt.framework/Versions/6/qwt
    install_name_tool -id @rpath/QtConcurrent.framework/Versions/5/QtConcurrent ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
    install_name_tool -id @rpath/QtPrintSupport.framework/Versions/5/QtPrintSupport ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
    install_name_tool -id @rpath/QtOpenGL.framework/Versions/5/QtOpenGL ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
    chmod -w ${app_frame_path}/qwt.framework/Versions/6/qwt
    chmod -w ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
    chmod -w ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
    chmod -w ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
  fi

fi

# Change all libs for cocoa

if [ "X$do_cocoa" = "Xtrue" ]
then
  chmod +w ${app_frame_path}/QtGui.framework/Versions/5/QtGui
  chmod +w ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg
  chmod +w ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets
  chmod +w ${app_frame_path}/QtCore.framework/Versions/5/QtCore
  chmod +w ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort
  chmod +w ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork

  install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtGui.framework/Versions/5/QtGui
  install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg
  install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtCore.framework/Versions/5/QtCore
  install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets
  install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort
  install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork

  chmod -w ${app_frame_path}/QtGui.framework/Versions/5/QtGui
  chmod -w ${app_frame_path}/QtSvg.framework/Versions/5/QtSvg
  chmod -w ${app_frame_path}/QtWidgets.framework/Versions/5/QtWidgets
  chmod -w ${app_frame_path}/QtCore.framework/Versions/5/QtCore
  chmod -w ${app_frame_path}/QtSerialPort.framework/Versions/5/QtSerialPort
  chmod -w ${app_frame_path}/QtNetwork.framework/Versions/5/QtNetwork

  if [ "X$do_qwt" = "Xtrue" ]
  then
    chmod +w ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
    chmod +w ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
    chmod +w ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL

    install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
    install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
    install_name_tool -change ${path_cocoa}/libqcocoa.dylib @rpath/../${plugplat}/libqcocoa.dylib ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL

    chmod -w ${app_frame_path}/QtConcurrent.framework/Versions/5/QtConcurrent
    chmod -w ${app_frame_path}/QtPrintSupport.framework/Versions/5/QtPrintSupport
    chmod -w ${app_frame_path}/QtOpenGL.framework/Versions/5/QtOpenGL
  fi
fi

# Check

otool -L ${app_binary_path}
echo
echo
otool -L ${app_frame_path}/QtGui.framework/QtGui
echo
echo
otool -L ${app_frame_path}/QtCore.framework/QtCore
echo
echo
otool -L ${app_frame_path}/QtSvg.framework/QtSvg
echo
echo
otool -L ${app_frame_path}/QtWidgets.framework/QtWidgets
echo 
echo
otool -L ${app_frame_path}/QtSerialPort.framework/QtSerialPort
echo
echo
otool -L ${app_frame_path}/QtNetwork.framework/QtNetwork
if [ "X$do_qwt" = "Xtrue" ]
then
  echo
  echo
  otool -L ${app_frame_path}/qwt.framework/qwt
  echo
  echo
  otool -L ${app_frame_path}/QtConcurrent.framework/QtConcurrent
  echo
  echo
  otool -L ${app_frame_path}/QtPrintSupport.framework/QtPrintSupport
  echo
  echo
  otool -L ${app_frame_path}/QtOpenGL.framework/QtOpenGL
fi
