package;

#if android
import android.Permissions;
import android.os.Build;
import android.os.Environment;
import android.widget.Toast;
#end
import flash.system.System;
import flixel.FlxG;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets;
import lime.system.System as LimeSystem;
#if (sys && !ios)
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

/**
 * ...
 * @author Mihai Alexandru (M.A. Jigsaw)
 */
class SUtil
{
        static final videoFiles:Array<String> = [
                "armorsteve"
        ];

	/**
	 * A simple function that checks for storage permissions and game files/folders
	 */
	public static function check()
	{
		#if android
		if (!Permissions.getGrantedPermissions().contains(Permissions.WRITE_EXTERNAL_STORAGE)
			&& !Permissions.getGrantedPermissions().contains(Permissions.READ_EXTERNAL_STORAGE))
		{
			if (VERSION.SDK_INT >= VERSION_CODES.M)
			{
				Permissions.requestPermissions([Permissions.WRITE_EXTERNAL_STORAGE, Permissions.READ_EXTERNAL_STORAGE]);

				/**
				 * Basically for now i can't force the app to stop while its requesting a android permission, so this makes the app to stop while its requesting the specific permission
				 */
				Lib.application.window.alert('You needed grant storage permission for save crash logs'
					+ '\nPress Ok to contiune',
					'Permissions?');
			}
			else
			{
				Lib.application.window.alert('Please grant the game storage permissions in app settings' + '\nPress Ok to close the app', 'Permissions?');
				LimeSystem.exit(1);
			}
		}
		if (!FileSystem.exists(SUtil.getPath()))
			FileSystem.createDirectory(SUtil.getPath());

                if (!FileSystem.exists(SUtil.getPath()))
		FileSystem.createDirectory(SUtil.getPath());

		if (!FileSystem.exists(SUtil.getPath() + 'assets'))
		FileSystem.createDirectory(SUtil.getPath() + 'assets');
 
		for (vid in videoFiles)
			copyContent(Paths.video(vid), SUtil.getPath() + Paths.video(vid));
		}
		#end
	}

	/**
	 * This returns the external storage path that the game will use
	 */
	public static function getPath():String
        {
		#if android
		var daPath = Context.getExternalFilesDir(null) + '/';

		SUtil.mkDirs(Path.directory(daPath));

		return daPath;
		#else
		return '';
		#end
	}

	/**
	 * Uncaught error handler, original made by: sqirra-rng
	 */
	public static function uncaughtErrorHandler():Void
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(u:UncaughtErrorEvent)
		{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var errMsg:String = '';

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case CFunction:
						errMsg += 'a C function\n';
					case Module(m):
						errMsg += 'module ' + m + '\n';
					case FilePos(s, file, line, column):
						errMsg += file + ' (line ' + line + ')\n';
					case Method(cname, meth):
						errMsg += cname == null ? "<unknown>" : cname + '.' + meth + '\n';
					case LocalFunction(n):
						errMsg += 'local function ' + n + '\n';
				}
			}

			errMsg += u.error;

			#if (sys && !ios)
			try
			{
				if (!FileSystem.exists(SUtil.getPath() + 'logs'))
					FileSystem.createDirectory(SUtil.getPath() + 'logs');

				File.saveContent(SUtil.getPath()
					+ 'logs/'
					+ Lib.application.meta.get('file')
					+ '-'
					+ Date.now().toString().replace(' ', '-').replace(':', "'")
					+ '.log',
					errMsg
					+ '\n');
			}
			#if android
			catch (e:Dynamic)
			Toast.makeText("Error!\nClouldn't save the crash dump because:\n" + e, Toast.LENGTH_LONG);
			#end
			#end

			println(errMsg);
			Lib.application.window.alert(errMsg, 'Error!');
			LimeSystem.exit(1);
		});
	}

        public static function mkDirs(directory:String):Void
	{
		if (FileSystem.exists(directory) && FileSystem.isDirectory(directory))
			return;

		var total:String = '';

		if (directory.substr(0, 1) == '/')
			total = '/';

		var parts:Array<String> = directory.split('/');

		if (parts.length > 0 && parts[0].indexOf(':') > -1)
			parts.shift();

		for (part in parts)
		{
			if (part != '.' && part != '')
			{
				if (total != '' && total != '/')
					total += '/';

				total += part;

				if (FileSystem.exists(total) && !FileSystem.isDirectory(total))
					FileSystem.deleteFile(total);

				if (!FileSystem.exists(total))
					FileSystem.createDirectory(total);
			}
		}
	}

        public static function copyContent(copyPath:String, savePath:String):Void
	{
		try
		{
			if (!FileSystem.exists(savePath) && Assets.exists(copyPath))
			{
				SUtil.mkDirs(Path.directory(savePath));
				File.saveBytes(savePath, Assets.getBytes(copyPath));
			}
		}
		#if android
		catch (e:Dynamic)
		Toast.makeText("Error!\nClouldn't copy the file because:\n" + e, Toast.LENGTH_LONG);
		#end
	}

	private static function println(msg:String):Void
	{
		#if sys
		Sys.println(msg);
		#else
		// Pass null to exclude the position.
		haxe.Log.trace(msg, null);
		#end
	}
}
