package scenes.td {
	import flash.display.Bitmap;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class RcsMgr {
		
		[Embed (source="../../../../res/tex/orbe_bk.jpg")]			private static var orbe_bkTexClass_:Class;
		[Embed (source="../../../../res/tex/orbe_dn.jpg")]			private static var orbe_dnTexClass_:Class;
		[Embed (source="../../../../res/tex/orbe_ft.jpg")]			private static var orbe_ftTexClass_:Class;
		[Embed (source="../../../../res/tex/orbe_lf.jpg")]			private static var orbe_lfTexClass_:Class;
		[Embed (source="../../../../res/tex/orbe_rt.jpg")]			private static var orbe_rtTexClass_:Class;
		[Embed (source="../../../../res/tex/box1b_d.jpg")]			private static var box1b_dTexClass_:Class;
		[Embed (source="../../../../res/tex/wall.jpg")]				private static var wallTexClass_:Class;
		[Embed (source="../../../../res/ui/window/metal.png")]		private static var uiMetalTexClass_:Class;
		[Embed (source="../../../../res/ui/buttons/metal_b.png")]	private static var uiButtonNTexClass_:Class;
		[Embed (source="../../../../res/ui/buttons/metal_f.png")]	private static var uiButtonOTexClass_:Class;
		[Embed (source="../../../../res/ui/buttons/metal_a.png")]	private static var uiButtonPTexClass_:Class;
		[Embed (source="../../../../res/ui/buttons/metal_i.png")]	private static var uiButtonITexClass_:Class;
		[Embed (source="../../../../res/mask.png")]					private static var maskTexClass_:Class;
		[Embed (source="../../../../res/water.jpg")]				private static var waterTexClass_:Class;
		[Embed (source="../../../../res/tex/portal.png")]			private static var portalTexClass_:Class;
		[Embed(source = "../../../../res/ui/icons/basic_up.png")]	private static var upTexClass_:Class;
		[Embed(source = "../../../../res/ui/icons/basic_down.png")]	private static var downTexClass_:Class;
		[Embed(source = "../../../../res/ui/icons/basic_left.png")]	private static var leftTexClass_:Class;
		[Embed(source = "../../../../res/ui/icons/basic_right.png")]private static var rightTexClass_:Class;

		[Embed(source = "../../../../res/tex/orbs/blue.jpg")]		private static var blueOrbTexClass_:Class;
		[Embed(source = "../../../../res/tex/orbs/red.jpg")]		private static var redOrbTexClass_:Class;
		[Embed(source = "../../../../res/tex/orbs/black.jpg")]		private static var blackOrbTexClass_:Class;
		[Embed(source = "../../../../res/tex/orbs/clear.jpg")]		private static var clearOrbTexClass_:Class;
		[Embed(source = "../../../../res/tex/orbs/purple.jpg")]		private static var purpleOrbTexClass_:Class;
		[Embed(source = "../../../../res/tex/orbs/green.jpg")]		private static var greenOrbTexClass_:Class;
		[Embed(source = "../../../../res/tex/orbs/amble.jpg")]		private static var amberOrbTexClass_:Class;

		[Embed (source="../../../../res/wall.md2", mimeType="application/octet-stream")] private static var wallMdlClass_:Class;

		[Embed (source="../../../../res/snd/shock.mp3")]			private static var shockWavClass_:Class;
		[Embed (source="../../../../res/snd/shock_target.mp3")]		private static var shocktargetWavClass_:Class;
		[Embed (source="../../../../res/snd/grd2wall.mp3")]			private static var grd2wallWavClass_:Class;
		[Embed (source="../../../../res/snd/wall2twr.mp3")]			private static var wall2twrWavClass_:Class;
		[Embed (source="../../../../res/snd/twr2wall.mp3")]			private static var twr2wallWavClass_:Class;
		[Embed (source="../../../../res/snd/wall2grd.mp3")]			private static var wall2grdWavClass_:Class;
		
		private static var texs_:Object = new Object();	// textures
		private static var snds_:Object = new Object();	// sounds
		private static var mdls_:Object = new Object();	// models
		//private var fnts_:Object = new Object();	// fonts
		
		static public function load():void {
			texs_["orbe_bk.jpg"] = new orbe_bkTexClass_();
			texs_["orbe_dn.jpg"] = new orbe_dnTexClass_();
			texs_["orbe_ft.jpg"] = new orbe_ftTexClass_();
			texs_["orbe_lf.jpg"] = new orbe_lfTexClass_();
			texs_["orbe_rt.jpg"] = new orbe_rtTexClass_();
			texs_["box1b_d.jpg"] = new box1b_dTexClass_();
			texs_["wall.jpg"] = new wallTexClass_();
			texs_["metal.png"] = new uiMetalTexClass_();
			texs_["btn_n.png"] = new uiButtonNTexClass_();
			texs_["btn_o.png"] = new uiButtonOTexClass_();
			texs_["btn_p.png"] = new uiButtonPTexClass_();
			texs_["btn_i.png"] = new uiButtonITexClass_();
			texs_["mask.png"] = new maskTexClass_();
			texs_["water.jpg"] = new waterTexClass_();
			texs_["portal.png"] = new portalTexClass_();
			texs_["arrow_up"] = new upTexClass_();
			texs_["arrow_down"] = new downTexClass_();
			texs_["arrow_left"] = new leftTexClass_();
			texs_["arrow_right"] = new rightTexClass_();

			texs_["blue_orb"] = new blueOrbTexClass_();
			texs_["red_orb"] = new redOrbTexClass_();
			texs_["black_orb"] = new blackOrbTexClass_();
			texs_["clear_orb"] = new clearOrbTexClass_();
			texs_["purple_orb"] = new purpleOrbTexClass_();
			texs_["green_orb"] = new greenOrbTexClass_();
			texs_["amber_orb"] = new amberOrbTexClass_();

			snds_["shock.mp3"] = new shockWavClass_();
			snds_["shock_target.mp3"] = new shocktargetWavClass_();
			snds_["grd2wall.mp3"] = new grd2wallWavClass_();
			snds_["wall2twr.mp3"] = new wall2twrWavClass_();
			snds_["twr2wall.mp3"] = new twr2wallWavClass_();
			snds_["wall2grd.mp3"] = new wall2grdWavClass_();

			mdls_["wall.md2"] = wallMdlClass_;
		}
		
		static public function unload():void {
			delete texs_["concrete.jpg"];
			delete texs_["graphite.png"];
			delete texs_["btn_n.png"];
			delete texs_["btn_o.png"];
			delete texs_["btn_p.png"];
			delete texs_["btn_i.png"];
		}
		
		static public function getTex(name:String):Bitmap {
			return texs_[name];
		}
		
		static public function getSound(name:String):Sound {
			return snds_[name];
		}
		
		static public function getModel(name:String):ByteArray {
			return new mdls_[name];
		}
		
	}
	
}