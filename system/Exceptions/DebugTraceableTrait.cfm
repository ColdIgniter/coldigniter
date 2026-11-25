<!---
 * This trait provides framework exceptions the ability to pinpoint
 * accurately where the exception was raised rather than instantiated.
 *
 * This is used primarily for factory-instantiated exceptions.
 *
 * Difference: nothing to include. The original sets the file and the line
 * of the exception in its constructor, to where it is raised. A cfthrow
 * is raised where it is written, and the tagContext of the caught error
 * starts there, so the position is right without this trait. The file is
 * kept for the file list of the original.
--->
