package org.pica.graphics.loader {
	import flash.display.Bitmap;
	import org.papervision3d.core.data.UserData;
	import org.papervision3d.events.FileLoadEvent;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.objects.parsers.DAE;
	import org.papervision3d.objects.parsers.KMZ;
	import org.papervision3d.objects.parsers.MD2;
	import org.papervision3d.materials.BitmapFileMaterial;
	import org.papervision3d.materials.special.CompositeMaterial;
	
	/**
	 * ...
	 * @author Darren Liew
	 */
	public class Object3D extends DisplayObject3D {
		[Embed(source = "D:/SmartFlex/pica/res/tex/concrete.jpg")]
		private var ConcreteBitmapClass:Class;
		
		public function Object3D(name:String) {
			this.name = name;
		}
		
		public function openModel(name:String, path:String, fname:String, onloaded:Function):void {
			var model:DisplayObject3D = this.getChildByName(name);
			if (model != null) {
				this.removeChild(model);
			}
			var type:String = fname.substr(fname.lastIndexOf(".") + 1, 3).toLowerCase();
			if (type == null)
				return;

			switch(type)
			{
			case "dae":
				model = new DAE(true, fname, true);
				DAE(model).load(path + fname);
				break;
			case "kmz":
				model = new KMZ(fname);
				KMZ(model).load(path + fname);
				break;
			case "md2":
				model = new MD2(true);
				var bmp:Bitmap = new ConcreteBitmapClass();
				MD2(model).load(path + fname, new BitmapMaterial(bmp.bitmapData));
				break;
			}
			if (onloaded != null) {
				var ud:UserData = new UserData(onloaded);
				model.userData = ud;
			}
			model.name = name;	
			model.addEventListener(FileLoadEvent.ANIMATIONS_COMPLETE, onLoaded);
		}
		
		public function reskinModel(name:String, path:String, fnames:Array, part:String):void {
			if (this.numChildren == 0) // no model yet
				return;

			var model:DisplayObject3D = this.getChildByName(name);
			if (model == null)
				return;
				
			var compMat:CompositeMaterial = new CompositeMaterial();
			for each (var fname:String in fnames) {
				compMat.addMaterial(new BitmapFileMaterial(path + fname));
			}
			model.replaceMaterialByName(compMat, part);
		}
		
		public function loaded():Boolean {
			return this.numChildren > 0;
		}
		
		public function getMaterialNameList(name:String):Array {
			var matList:Array = new Array();
			matList.push(new BitmapMaterial());
			var obj:DisplayObject3D = this.getChildByName(name);
			if (obj == null) return matList;
			
			matList = recursiveMatName(obj);
			
			// filter away empty ele caused additional '\n' in org.papervision3d.materials.utils.MaterialList toString()
			matList = matList.filter(function(ele:*, i:int, arr:Array):Boolean { return ele != ""; } );
				
			matList.sort();

			return matList;
		}
		
		public function getNodeNameList(name:String):Array {
			var nodeList:Array = new Array();
			var obj:DisplayObject3D = this.getChildByName(name);
			if (obj == null) return nodeList;

			nodeList = recursiveNodeName(obj);
				
			nodeList.sort();

			return nodeList;
		}
		
		private function recursiveMatName(obj:DisplayObject3D):Array {
			var list:Array = new Array();
			
			if (obj.numChildren != 0) {
				var cont:Object = obj.children;
				for each (var child:DisplayObject3D in cont)
					list = list.concat(recursiveMatName(child));
			}
			
			if (obj.materials != null && obj.materials.numMaterials != 0)
				list = list.concat(obj.materials.toString().split("\n"));
			
			return list;
		}
		
		private function recursiveNodeName(obj:DisplayObject3D):Array {
			var list:Array = new Array();

			if (obj.numChildren != 0) {
				var cont:Object = obj.children;
				for each (var child:DisplayObject3D in cont)
					list = list.concat(recursiveNodeName(child));
			}
			
			list.push(obj.name);
			
			return list;
		}
		
		private function onLoaded(evt:FileLoadEvent):void {
			var model:DisplayObject3D = evt.target as DisplayObject3D;
			model.removeEventListener(FileLoadEvent.ANIMATIONS_COMPLETE, onLoaded);
			this.addChild(model);
			var func:Function = model.userData.data as Function;
			func(model);
		}
		
	}
	
}