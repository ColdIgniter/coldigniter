<!---
 * Paths
 *
 * Holds the paths that are used by the system to
 * locate the main directories, app, system, etc.
 *
 * Modifying these allows you to restructure your application,
 * share a system folder between multiple applications, and more.
 *
 * All paths are relative to the folder this file is in (app/Config).
 * Use forward slashes. The folders must be on the same drive as
 * the front controller.
 *
 * NOTE: This file is included before anything else is loaded, so it
 *       is a plain settings file and not a component.
--->
<cfset paths = StructNew()>

<!---
 * ---------------------------------------------------------------
 * SYSTEM FOLDER NAME
 * ---------------------------------------------------------------
 *
 * This must contain the name of your "system" folder. Include
 * the path if the folder is not next to the "app" folder.
--->
<cfset paths.systemDirectory = "../../system">

<!---
 * ---------------------------------------------------------------
 * APPLICATION FOLDER NAME
 * ---------------------------------------------------------------
 *
 * The "app" folder, which is the parent of this folder. If you
 * rename or move it, change "appDirectory" in the front controller
 * (public/index.cfm) and leave this value alone.
--->
<cfset paths.appDirectory = "..">

<!---
 * ---------------------------------------------------------------
 * WRITABLE DIRECTORY NAME
 * ---------------------------------------------------------------
 *
 * This variable must contain the name of your "writable" directory.
 * The writable directory allows you to group all directories that
 * need write permission to a single place that can be tucked away
 * for maximum security, keeping it out of the app and/or
 * system directories.
--->
<cfset paths.writableDirectory = "../../writable">

<!---
 * ---------------------------------------------------------------
 * TESTS DIRECTORY NAME
 * ---------------------------------------------------------------
 *
 * This variable must contain the name of your "tests" directory.
--->
<cfset paths.testsDirectory = "../../tests">

<!---
 * ---------------------------------------------------------------
 * VIEW DIRECTORY NAME
 * ---------------------------------------------------------------
 *
 * This variable must contain the name of the directory that
 * contains the view files used by your application. By
 * default this is in "app/Views".
--->
<cfset paths.viewDirectory = "../Views">

<!---
 * ---------------------------------------------------------------
 * ENVIRONMENT DIRECTORY NAME
 * ---------------------------------------------------------------
 *
 * This variable must contain the name of the directory where
 * the .env file is located.
 * Please consider security implications when changing this
 * value - the directory should not be publicly accessible.
--->
<cfset paths.envDirectory = "../..">
