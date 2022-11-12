#if android
import extension.videoview.VideoView;
#end
import flixel.FlxBasic;

class DaCutscene extends FlxBasic {
	public var finishCallback:Void->Void = null;

	public function new(name:String) {
		super();

	        #if android
                VideoView.playVideo(SUtil.getPath() + 'assets/videos/armorsteve.webm');
                VideoView.onCompletion = function(){
		        if (finishCallback != null){
			        finishCallback();
		        }
                }
		#end
	}
}
