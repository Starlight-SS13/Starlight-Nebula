/**
 * A function to wrap calls to DLLs for debugging purposes.
 */
/proc/dll_call(dll, func, ...)

	if(!fexists(dll))
		to_world_log("Unable to locate dll at [dll].")
		return

	var/start = world.timeofday

	var/list/calling_arguments = length(args) > 2 ? args.Copy(3) : null

	. = call(dll, func)(arglist(calling_arguments))

	if (world.timeofday - start > 10 SECONDS)
		CRASH("DLL call took longer than 10 seconds: [func]")
