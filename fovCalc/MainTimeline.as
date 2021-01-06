package fovCalc_new2_fla
{
   import fl.controls.Button;
   import fl.controls.ComboBox;
   import fl.controls.Slider;
   import fl.data.DataProvider;
   import fl.data.SimpleCollectionItem;
   import fl.events.SliderEvent;
   import fl.motion.AnimatorFactory3D;
   import fl.motion.MotionBase;
   import fl.motion.motion_internal;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.Graphics;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.net.URLLoader;
   import flash.net.URLLoaderDataFormat;
   import flash.net.URLRequest;
   import flash.net.URLRequestMethod;
   import flash.net.URLVariables;
   import flash.net.navigateToURL;
   import flash.text.TextField;
   
   public dynamic class MainTimeline extends MovieClip
   {
       
      
      public var monSizeLabel:TextField;
      
      public var numMonLabelR:TextField;
      
      public var gameLabel:TextField;
      
      public var gameLabelR:TextField;
      
      public var outline:MovieClip;
      
      public var disclaimerText:TextField;
      
      public var fovTypeLabelR:TextField;
      
      public var titleImg:MovieClip;
      
      public var fovBasedOnText:TextField;
      
      public var numMonLabel:TextField;
      
      public var donateButton:MovieClip;
      
      public var monSizeSliderText:TextField;
      
      public var monSizeLabelR:TextField;
      
      public var unitSelect:ComboBox;
      
      public var ratioSelect:ComboBox;
      
      public var calcButton:Button;
      
      public var mon1:MovieClip;
      
      public var head:MovieClip;
      
      public var distToMonLabel:TextField;
      
      public var ratioLabel:TextField;
      
      public var closeFovInfo:TextField;
      
      public var fovText:TextField;
      
      public var pleaseHelpText:TextField;
      
      public var donateText:TextField;
      
      public var fovInfo:MovieClip;
      
      public var distText:TextField;
      
      public var distToMonLabelR:TextField;
      
      public var gameSelect:ComboBox;
      
      public var ratioLabelR:TextField;
      
      public var slider:Slider;
      
      public var fovTypeLabel:TextField;
      
      public var numMonSelect:ComboBox;
      
      public var screenShot:Loader;
      
      public var changesMade:Number;
      
      public var monSize:Number;
      
      public var monQty:Number;
      
      public var distToMon:Number;
      
      public var fovType:String;
      
      public var topDistArrow:Sprite;
      
      public var ga:Graphics;
      
      public var monFrame:Sprite;
      
      public var monRatio:String;
      
      public var monRatioArray2:Array;
      
      public var game:String;
      
      public var gameText:String;
      
      public var ratioMultiplier:Number;
      
      public var screenWidth:Number;
      
      public var screenHeight:Number;
      
      public var calc:Number;
      
      public var angle:Number;
      
      public var angleRad:Number;
      
      public var fovAngle:Number;
      
      public var fov:String;
      
      public var basefov:Number;
      
      public var mf:Graphics;
      
      public var scw:int;
      
      public var sch:int;
      
      public var mfx:int;
      
      public var mfy:int;
      
      public var mfw:int;
      
      public var mfh:int;
      
      public var mff:int;
      
      public var screenShotUrl:String;
      
      public var minFOV:Number;
      
      public var maxFOV:Number;
      
      public var radAngle:Number;
      
      public var imageLoaded:Boolean;
      
      public var pieceWidth:Number;
      
      public var pieceHeight:Number;
      
      public var newAngleRad:Number;
      
      public var newScreenHeight:Number;
      
      public var scale:Number;
      
      public var newScreenWidth:Number;
      
      public var distUnit:String;
      
      public var unit:String;
      
      public var __animFactory_headaf1:AnimatorFactory3D;
      
      public var __animArray_headaf1:Array;
      
      public var ____motion_headaf1_mat3DVec__:Vector.<Number>;
      
      public var ____motion_headaf1_matArray__:Array;
      
      public var __motion_headaf1:MotionBase;
      
      public var __animFactory_outlineaf1:AnimatorFactory3D;
      
      public var __animArray_outlineaf1:Array;
      
      public var ____motion_outlineaf1_mat3DVec__:Vector.<Number>;
      
      public var ____motion_outlineaf1_matArray__:Array;
      
      public var __motion_outlineaf1:MotionBase;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1);
         addEventListener(Event.ADDED_TO_STAGE,this.__setPerspectiveProjection_);
         if(this.__animFactory_headaf1 == null)
         {
            this.__animArray_headaf1 = new Array();
            this.__motion_headaf1 = new MotionBase();
            this.__motion_headaf1.duration = 1;
            this.__motion_headaf1.overrideTargetTransform();
            this.__motion_headaf1.addPropertyArray("visible",[true]);
            this.__motion_headaf1.addPropertyArray("cacheAsBitmap",[false]);
            this.__motion_headaf1.addPropertyArray("blendMode",["normal"]);
            this.__motion_headaf1.addPropertyArray("opaqueBackground",[null]);
            this.__motion_headaf1.is3D = true;
            this.__motion_headaf1.motion_internal::spanStart = 0;
            this.____motion_headaf1_matArray__ = new Array();
            this.____motion_headaf1_mat3DVec__ = new Vector.<Number>(16);
            this.____motion_headaf1_mat3DVec__[0] = 1;
            this.____motion_headaf1_mat3DVec__[1] = 0;
            this.____motion_headaf1_mat3DVec__[2] = 0;
            this.____motion_headaf1_mat3DVec__[3] = 0;
            this.____motion_headaf1_mat3DVec__[4] = 0;
            this.____motion_headaf1_mat3DVec__[5] = 1;
            this.____motion_headaf1_mat3DVec__[6] = 0;
            this.____motion_headaf1_mat3DVec__[7] = 0;
            this.____motion_headaf1_mat3DVec__[8] = 0;
            this.____motion_headaf1_mat3DVec__[9] = 0;
            this.____motion_headaf1_mat3DVec__[10] = 1;
            this.____motion_headaf1_mat3DVec__[11] = 0;
            this.____motion_headaf1_mat3DVec__[12] = 350;
            this.____motion_headaf1_mat3DVec__[13] = 475;
            this.____motion_headaf1_mat3DVec__[14] = 0;
            this.____motion_headaf1_mat3DVec__[15] = 1;
            this.____motion_headaf1_matArray__.push(new Matrix3D(this.____motion_headaf1_mat3DVec__));
            this.__motion_headaf1.addPropertyArray("matrix3D",this.____motion_headaf1_matArray__);
            this.__animArray_headaf1.push(this.__motion_headaf1);
            this.__animFactory_headaf1 = new AnimatorFactory3D(null,this.__animArray_headaf1);
            this.__animFactory_headaf1.sceneName = "Scene 1";
            this.__animFactory_headaf1.addTargetInfo(this,"head",0,true,0,true,null,-1);
         }
         if(this.__animFactory_outlineaf1 == null)
         {
            this.__animArray_outlineaf1 = new Array();
            this.__motion_outlineaf1 = new MotionBase();
            this.__motion_outlineaf1.duration = 1;
            this.__motion_outlineaf1.overrideTargetTransform();
            this.__motion_outlineaf1.addPropertyArray("visible",[true]);
            this.__motion_outlineaf1.addPropertyArray("cacheAsBitmap",[false]);
            this.__motion_outlineaf1.addPropertyArray("blendMode",["normal"]);
            this.__motion_outlineaf1.addPropertyArray("opaqueBackground",[null]);
            this.__motion_outlineaf1.is3D = true;
            this.__motion_outlineaf1.motion_internal::spanStart = 0;
            this.____motion_outlineaf1_matArray__ = new Array();
            this.____motion_outlineaf1_mat3DVec__ = new Vector.<Number>(16);
            this.____motion_outlineaf1_mat3DVec__[0] = 1;
            this.____motion_outlineaf1_mat3DVec__[1] = 0;
            this.____motion_outlineaf1_mat3DVec__[2] = 0;
            this.____motion_outlineaf1_mat3DVec__[3] = 0;
            this.____motion_outlineaf1_mat3DVec__[4] = 0;
            this.____motion_outlineaf1_mat3DVec__[5] = 1;
            this.____motion_outlineaf1_mat3DVec__[6] = 0;
            this.____motion_outlineaf1_mat3DVec__[7] = 0;
            this.____motion_outlineaf1_mat3DVec__[8] = 0;
            this.____motion_outlineaf1_mat3DVec__[9] = 0;
            this.____motion_outlineaf1_mat3DVec__[10] = 1;
            this.____motion_outlineaf1_mat3DVec__[11] = 0;
            this.____motion_outlineaf1_mat3DVec__[12] = 400;
            this.____motion_outlineaf1_mat3DVec__[13] = 200;
            this.____motion_outlineaf1_mat3DVec__[14] = 0;
            this.____motion_outlineaf1_mat3DVec__[15] = 1;
            this.____motion_outlineaf1_matArray__.push(new Matrix3D(this.____motion_outlineaf1_mat3DVec__));
            this.__motion_outlineaf1.addPropertyArray("matrix3D",this.____motion_outlineaf1_matArray__);
            this.__animArray_outlineaf1.push(this.__motion_outlineaf1);
            this.__animFactory_outlineaf1 = new AnimatorFactory3D(null,this.__animArray_outlineaf1);
            this.__animFactory_outlineaf1.sceneName = "Scene 1";
            this.__animFactory_outlineaf1.addTargetInfo(this,"outline",0,true,0,true,null,-1);
         }
         this.__setProp_ratioSelect_Scene1_comboBoxes_0();
         this.__setProp_numMonSelect_Scene1_comboBoxes_0();
         this.__setProp_gameSelect_Scene1_comboBoxes_0();
         this.__setProp_unitSelect_Scene1_comboBoxes_0();
         this.__setProp_slider_Scene1_slider_0();
         this.__setProp_calcButton_Scene1_calcButton_0();
      }
      
      public function init() : void
      {
         stage.addEventListener(Event.ENTER_FRAME,this.loop);
      }
      
      public function setupFrame() : void
      {
         this.changesMade = 1;
         this.monQty = 1;
         this.monSize = 24;
         this.distToMon = 29;
         this.head.x = 350;
         this.monRatio = "16:9";
         this.distUnit = "inches";
         this.unit = "\"";
         this.game = "AC";
         this.gameText = "Assetto Corsa";
         this.fovType = "Vertical, Degrees";
         this.ratioMultiplier = 0;
         this.screenWidth = 27.89;
         this.screenHeight = 15.69;
         this.calc = 0;
         this.angle = 0;
         this.angleRad = 0;
         this.fovAngle = 0;
         this.fov = "0";
         this.basefov = 58;
         this.outline.alpha = 0.5;
         this.screenShotUrl = "AC.png";
         this.minFOV = 10;
         this.maxFOV = 120;
         this.fovInfo.visible = false;
         this.fovText.visible = false;
         this.numMonLabelR.visible = false;
         this.ratioLabelR.visible = false;
         this.gameLabelR.visible = false;
         this.fovTypeLabelR.visible = false;
         this.distToMonLabelR.visible = false;
         this.monSizeLabelR.visible = false;
         this.closeFovInfo.visible = false;
         this.closeFovInfo.visible = false;
         this.fovBasedOnText.visible = false;
         this.donateButton.visible = false;
         this.titleImg.visible = false;
         this.disclaimerText.visible = false;
      }
      
      public function moveHeadStart(param1:MouseEvent) : void
      {
         this.head.startDrag(false,new Rectangle(350,430,0,150));
         this.head.addEventListener(MouseEvent.MOUSE_MOVE,this.onHeadMove);
      }
      
      public function moveHeadStop(param1:MouseEvent) : void
      {
         this.head.stopDrag();
         removeEventListener(MouseEvent.MOUSE_MOVE,this.onHeadMove);
      }
      
      public function onHeadMove(param1:MouseEvent) : void
      {
         this.distToMon = (this.head.y - 430) / 5 + 20;
         this.changesMade = 1;
      }
      
      public function monSizeChanged(param1:SliderEvent) : void
      {
         this.monSize = param1.target.value;
         this.changesMade = 1;
      }
      
      public function monQtyChanged(param1:Event) : void
      {
         this.monQty = param1.currentTarget.selectedItem.data;
         if(this.monQty == 3)
         {
            this.slider.maximum = 55;
         }
         else
         {
            this.slider.maximum = 100;
         }
         this.monSize = this.slider.value;
         this.changesMade = 1;
      }
      
      public function monRatioChanged(param1:Event) : void
      {
         this.monRatio = param1.currentTarget.selectedItem.data;
         this.changesMade = 1;
      }
      
      public function distUnitChanged(param1:Event) : void
      {
         this.distUnit = param1.currentTarget.selectedItem.data;
         switch(this.distUnit)
         {
            case "inches":
               this.unit = "\"";
               break;
            case "cm":
               this.unit = "cm";
         }
         this.changesMade = 1;
      }
      
      public function showDistInUnit(param1:*, param2:*) : *
      {
         var _loc3_:String = null;
         switch(param2)
         {
            case "\"":
               _loc3_ = Math.round(param1 * 10) / 10 + param2;
               break;
            case "cm":
               _loc3_ = Math.round(param1 * 2.54) + param2;
         }
         return _loc3_;
      }
      
      public function gameChanged(param1:Event) : void
      {
         this.game = param1.currentTarget.selectedItem.data;
         this.changesMade = 1;
      }
      
      public function changeMonSize(param1:*) : void
      {
         this.mon1.width = int(param1 * 5) + 10;
         if(this.monQty == 3)
         {
            if(this.mon1.width > 285)
            {
               this.mon1.width = 285;
            }
         }
         this.mon1.x = 400 - this.mon1.width / 2;
      }
      
      public function screenSize() : void
      {
         var _loc1_:Array = this.monRatio.split(":");
         this.ratioMultiplier = _loc1_[1] / _loc1_[0];
         this.screenWidth = Math.cos(Math.atan(this.ratioMultiplier)) * this.monSize;
         this.screenHeight = Math.sin(Math.atan(this.ratioMultiplier)) * this.monSize;
      }
      
      public function calcFOV() : void
      {
         if(this.game == "pCARS" || this.game == "RBR")
         {
            this.calc = this.screenWidth;
         }
         else
         {
            this.calc = this.screenHeight;
         }
         this.angleRad = Math.atan(this.calc / 2 / this.distToMon) * 2;
         this.fovAngle = this.angleRad * 180 / Math.PI;
         if(this.game == "rf2")
         {
            this.gameText = "rFactor 1 & 2, GSC, GSCE, SCE, AMS";
            this.fovType = "Vertical, Degrees";
            this.minFOV = 10;
            this.maxFOV = 100;
            if(this.fovAngle > this.maxFOV)
            {
               this.fovAngle = this.maxFOV;
            }
            if(this.fovAngle < this.minFOV)
            {
               this.fovAngle = this.minFOV;
            }
            this.fovAngle = Math.round(this.fovAngle);
         }
         if(this.game == "AC")
         {
            this.gameText = "Assetto Corsa";
            this.fovType = "Vertical, Degrees";
            this.minFOV = 10;
            this.maxFOV = 120;
            if(this.fovAngle > this.maxFOV)
            {
               this.fovAngle = this.maxFOV;
            }
            if(this.fovAngle < this.minFOV)
            {
               this.fovAngle = this.minFOV;
            }
            this.fovAngle = int(this.fovAngle * 100) / 100;
         }
         this.fov = this.fovAngle + "° (vFOV)";
         if(this.game == "pCARS")
         {
            this.gameText = "Project Cars";
            this.fovType = "Horizontal, Degrees";
            this.fovAngle = this.fovAngle * this.monQty;
            this.minFOV = 35;
            this.maxFOV = 180;
            if(this.fovAngle > this.maxFOV)
            {
               this.fovAngle = this.maxFOV;
            }
            if(this.fovAngle < this.minFOV)
            {
               this.fovAngle = this.minFOV;
            }
            this.fov = Math.round(this.fovAngle) + "° (hFOV)";
         }
         if(this.game == "RBR")
         {
            this.gameText = "Richard Burns Rally";
            this.fovType = "Horizontal, Radians";
            this.fovAngle = this.fovAngle * this.monQty;
            this.minFOV = 10;
            this.maxFOV = 180;
            if(this.fovAngle > this.maxFOV)
            {
               this.fovAngle = this.maxFOV;
            }
            if(this.fovAngle < this.minFOV)
            {
               this.fovAngle = this.minFOV;
            }
            this.radAngle = this.fovAngle * (Math.PI / 180);
            this.fov = Math.round(this.radAngle * 1000000) / 1000000 + " (hFOVrad)";
         }
         if(this.game == "GAS")
         {
            this.gameText = "GRID Autosport, DiRT Rally";
            this.fovType = "Vertical, Degrees x2";
            this.minFOV = 10;
            this.maxFOV = 115;
            if(this.fovAngle > this.maxFOV)
            {
               this.fovAngle = this.maxFOV;
            }
            if(this.fovAngle < this.minFOV)
            {
               this.fovAngle = this.minFOV;
            }
            this.fovAngle = int(this.fovAngle * 100) / 100;
            this.fov = Math.round(this.fovAngle * 2) + " (vFOV°*2)";
         }
         if(this.game == "RRRE")
         {
            this.gameText = "RaceRoom Racing Experience";
            this.fovType = "Vertical, Multiplier of base FOV";
            if(this.monQty == 3)
            {
               this.basefov = 40;
            }
            else
            {
               this.basefov = 58;
            }
            this.minFOV = this.basefov * 0.5;
            this.maxFOV = this.basefov * 1.3;
            if(this.fovAngle > this.maxFOV)
            {
               this.fovAngle = this.maxFOV;
            }
            if(this.fovAngle < this.minFOV)
            {
               this.fovAngle = this.minFOV;
            }
            this.fov = int(this.fovAngle / this.basefov * 10) / 10 + "x (vFOV)";
         }
         if(this.game == "GTR2")
         {
            this.gameText = "GTR2";
            this.fovType = "Vertical, Multiplier of base FOV";
            this.basefov = 58;
            this.minFOV = this.basefov * 0.5;
            this.maxFOV = this.basefov * 1.5;
            if(this.fovAngle > this.maxFOV)
            {
               this.fovAngle = this.maxFOV;
            }
            if(this.fovAngle < this.minFOV)
            {
               this.fovAngle = this.minFOV;
            }
            this.fov = int(this.fovAngle / this.basefov * 10) / 10 + "x (vFOV)";
         }
         if(this.game == "Race07")
         {
            this.gameText = "Race 07, Race07 Evo";
            this.fovType = "Vertical, percentage of base FOV";
            this.basefov = 58;
            this.minFOV = this.basefov * 0.4;
            this.maxFOV = this.basefov * 1.5;
            if(this.fovAngle > this.maxFOV)
            {
               this.fovAngle = this.maxFOV;
            }
            if(this.fovAngle < this.minFOV)
            {
               this.fovAngle = this.minFOV;
            }
            this.fov = int(this.fovAngle / this.basefov * 100) + "% (vFOV)";
         }
      }
      
      public function loadScreenShot() : void
      {
         this.screenShotUrl = this.game + ".png";
         var _loc1_:URLRequest = new URLRequest("images/" + this.screenShotUrl);
         this.screenShot.load(_loc1_);
         this.screenShot.contentLoaderInfo.addEventListener(Event.COMPLETE,this.drawScreenShot);
      }
      
      public function drawScreenShot(param1:Event) : void
      {
         removeChildAt(0);
         this.mf.clear();
         if(this.game != "pCARS" && this.game != "RBR")
         {
            this.newAngleRad = this.fovAngle * (Math.PI / 180);
            this.newScreenHeight = Math.tan(this.newAngleRad / 2) * 25 * 2;
            this.scale = this.screenHeight / this.newScreenHeight;
            this.newScreenWidth = this.screenWidth / this.scale;
         }
         if(this.game == "pCARS")
         {
            if(this.monQty == 3)
            {
               this.fovAngle = this.fovAngle + 18;
               this.fovAngle = this.fovAngle / 3;
            }
            this.newAngleRad = (this.fovAngle + 15) * (Math.PI / 180);
            this.newScreenWidth = Math.tan(this.newAngleRad / 2) * 25 * 2;
            this.scale = this.screenWidth / this.newScreenWidth;
            this.newScreenHeight = this.screenHeight / this.scale;
         }
         if(this.game == "RBR")
         {
            if(this.monQty == 3)
            {
               this.fovAngle = this.fovAngle / 2;
            }
            else
            {
               this.fovAngle = this.fovAngle + 20;
            }
            this.newAngleRad = this.fovAngle * (Math.PI / 180);
            this.newScreenWidth = Math.tan(this.newAngleRad / 2) * 25 * 2;
            this.scale = this.screenWidth / this.newScreenWidth;
            this.newScreenHeight = this.screenHeight / this.scale;
         }
         var _loc2_:Bitmap = Bitmap(param1.target.loader.content);
         this.pieceWidth = int(this.newScreenWidth * 5) - 2;
         this.pieceHeight = int(this.newScreenHeight * 5) - 2;
         if(this.monQty == 3)
         {
            this.pieceWidth = this.pieceWidth * 3;
         }
         var _loc3_:Bitmap = new Bitmap(new BitmapData(this.pieceWidth,this.pieceHeight,false,0));
         _loc3_.bitmapData.copyPixels(_loc2_.bitmapData,new Rectangle(758 / 2 - this.pieceWidth / 2,310 / 2 - this.pieceHeight / 2,this.pieceWidth,this.pieceHeight),new Point(0,0));
         _loc3_.smoothing = true;
         var _loc4_:Sprite = new Sprite();
         _loc4_.addChild(_loc3_);
         addChildAt(_loc4_,0);
         _loc4_.scaleX = _loc4_.scaleY = this.scale;
         this.mff = 4;
         _loc4_.x = stage.stageWidth / 2 - _loc4_.width / 2 + this.mff;
         _loc4_.y = (340 - _loc4_.height) / 2 + this.mff;
         this.mfx = _loc4_.x - this.mff / 2;
         this.mfy = _loc4_.y - this.mff / 2;
         this.mfw = _loc4_.width + this.mff / 2;
         this.mfh = _loc4_.height + this.mff / 2;
         this.mf.lineStyle(4,0);
         this.mf.drawRect(this.mfx,this.mfy,this.mfw,this.mfh);
         if(this.monQty == 3)
         {
            this.mf.moveTo(this.mfx + _loc4_.width / 3,this.mfy);
            this.mf.lineTo(this.mfx + _loc4_.width / 3,this.mfy + _loc4_.height);
            this.mf.moveTo(this.mfx + _loc4_.width / 3 * 2,this.mfy);
            this.mf.lineTo(this.mfx + _loc4_.width / 3 * 2,this.mfy + _loc4_.height);
         }
         addChildAt(this.monFrame,8);
      }
      
      public function updateTextFields() : void
      {
         this.numMonLabel.text = "Number of Monitors: " + this.monQty;
         this.ratioLabel.text = "Monitor Ratio: " + this.monRatio;
         this.gameLabel.text = "Game: " + this.gameText;
         this.fovTypeLabel.text = "FOV Type, Unit: " + this.fovType;
         this.distText.text = this.showDistInUnit(this.distToMon,this.unit);
         this.distToMonLabel.text = "Distance to Screen: " + this.showDistInUnit(this.distToMon,this.unit);
         this.monSizeLabel.text = "Monitor Size (diagonal): " + this.monSize + "\"";
         this.monSizeSliderText.text = "Slide to change monitor size (diagonal): " + this.monSize + "\"";
         this.distText.y = this.mon1.y + 35 + (this.head.y - (this.mon1.y + 30)) / 2;
      }
      
      public function drawArrows() : void
      {
         var _loc1_:* = this.head.y - this.mon1.y;
         this.ga.clear();
         this.ga.lineStyle(0,16711680,0.5);
         this.ga.beginFill(16748544,0.5);
         this.ga.moveTo(4,0);
         this.ga.lineTo(9,9);
         this.ga.lineTo(0,9);
         this.ga.lineTo(4,0);
         this.ga.moveTo(4,33);
         this.ga.lineTo(4,_loc1_ / 2 - 10);
         this.ga.moveTo(4,_loc1_ / 2 + 10);
         this.ga.lineTo(4,_loc1_ - 37);
         this.ga.moveTo(0,_loc1_ - 37);
         this.ga.lineTo(9,_loc1_ - 37);
         this.ga.lineTo(4,_loc1_ - 37 + 9);
         this.ga.endFill();
         addChild(this.topDistArrow);
         this.topDistArrow.x = 396;
         this.topDistArrow.y = this.mon1.y + 29;
      }
      
      public function submitted(param1:MouseEvent) : *
      {
         var _loc2_:URLRequest = new URLRequest("http://www.projectimmersion.com/fov/phpMySql.php");
         _loc2_.method = URLRequestMethod.POST;
         var _loc3_:URLVariables = new URLVariables();
         _loc2_.data = _loc3_;
         var _loc4_:URLLoader = new URLLoader();
         _loc4_.dataFormat = URLLoaderDataFormat.VARIABLES;
         _loc4_.addEventListener(Event.COMPLETE,this.onCalc);
         _loc4_.load(_loc2_);
         this.changesMade = 1;
      }
      
      public function onCalc(param1:Event) : *
      {
         this.numMonLabelR.text = this.numMonLabel.text;
         this.ratioLabelR.text = this.ratioLabel.text;
         this.gameLabelR.text = this.gameLabel.text;
         this.fovTypeLabelR.text = this.fovTypeLabel.text;
         this.distToMonLabelR.text = this.distToMonLabel.text;
         this.monSizeLabelR.text = this.monSizeLabel.text;
         this.fovText.text = this.fov;
         this.numMonLabelR.visible = true;
         this.ratioLabelR.visible = true;
         this.gameLabelR.visible = true;
         this.fovTypeLabelR.visible = true;
         this.distToMonLabelR.visible = true;
         this.monSizeLabelR.visible = true;
         this.fovInfo.visible = true;
         this.fovText.visible = true;
         this.closeFovInfo.visible = true;
         this.fovBasedOnText.visible = true;
         this.donateButton.visible = true;
         this.titleImg.visible = true;
         this.disclaimerText.visible = true;
         this.topDistArrow.visible = false;
      }
      
      public function donate(param1:MouseEvent) : void
      {
         var _loc2_:URLRequest = new URLRequest("https://www.paypal.com/cgi-bin/webscr");
         _loc2_.method = URLRequestMethod.POST;
         var _loc3_:URLVariables = new URLVariables();
         _loc3_.cmd = "_s-xclick";
         _loc3_.hosted_button_id = "TBAX6K6ASGKDG";
         _loc2_.data = _loc3_;
         navigateToURL(_loc2_);
      }
      
      public function onFovClose(param1:Event) : *
      {
         this.fovInfo.visible = false;
         this.fovText.visible = false;
         this.numMonLabelR.visible = false;
         this.ratioLabelR.visible = false;
         this.gameLabelR.visible = false;
         this.fovTypeLabelR.visible = false;
         this.distToMonLabelR.visible = false;
         this.monSizeLabelR.visible = false;
         this.closeFovInfo.visible = false;
         this.fovBasedOnText.visible = false;
         this.donateButton.visible = false;
         this.titleImg.visible = false;
         this.disclaimerText.visible = false;
         this.topDistArrow.visible = true;
      }
      
      public function setContent() : void
      {
         this.screenSize();
         this.changeMonSize(this.screenWidth);
         this.calcFOV();
         this.drawArrows();
         this.updateTextFields();
         this.loadScreenShot();
      }
      
      public function loop(param1:Event) : void
      {
         if(this.changesMade == 1)
         {
            this.setContent();
            this.changesMade = 0;
         }
      }
      
      public function __setPerspectiveProjection_(param1:Event) : void
      {
         root.transform.perspectiveProjection.fieldOfView = 74.265168;
         root.transform.perspectiveProjection.projectionCenter = new Point(275,200);
      }
      
      function __setProp_ratioSelect_Scene1_comboBoxes_0() : *
      {
         var _loc2_:SimpleCollectionItem = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:* = undefined;
         try
         {
            this.ratioSelect["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         var _loc1_:DataProvider = new DataProvider();
         _loc3_ = [{
            "label":"16:9",
            "data":"16:9"
         },{
            "label":"16:10",
            "data":"16:10"
         },{
            "label":"21:9",
            "data":"21:9"
         },{
            "label":"5:4",
            "data":"5:4"
         },{
            "label":"4:3",
            "data":"4:3"
         },{
            "label":"32:9",
            "data":"32:9"
         }];
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc2_ = new SimpleCollectionItem();
            _loc4_ = _loc3_[_loc5_];
            for(_loc6_ in _loc4_)
            {
               _loc2_[_loc6_] = _loc4_[_loc6_];
            }
            _loc1_.addItem(_loc2_);
            _loc5_++;
         }
         this.ratioSelect.dataProvider = _loc1_;
         this.ratioSelect.editable = true;
         this.ratioSelect.enabled = true;
         this.ratioSelect.prompt = "Ratio";
         this.ratioSelect.restrict = "";
         this.ratioSelect.rowCount = 5;
         this.ratioSelect.visible = true;
         try
         {
            this.ratioSelect["componentInspectorSetting"] = false;
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      function __setProp_numMonSelect_Scene1_comboBoxes_0() : *
      {
         var _loc2_:SimpleCollectionItem = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:* = undefined;
         try
         {
            this.numMonSelect["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         var _loc1_:DataProvider = new DataProvider();
         _loc3_ = [{
            "label":"Single",
            "data":1
         },{
            "label":"Triple",
            "data":3
         }];
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc2_ = new SimpleCollectionItem();
            _loc4_ = _loc3_[_loc5_];
            for(_loc6_ in _loc4_)
            {
               _loc2_[_loc6_] = _loc4_[_loc6_];
            }
            _loc1_.addItem(_loc2_);
            _loc5_++;
         }
         this.numMonSelect.dataProvider = _loc1_;
         this.numMonSelect.editable = true;
         this.numMonSelect.enabled = true;
         this.numMonSelect.prompt = "# Monitors";
         this.numMonSelect.restrict = "";
         this.numMonSelect.rowCount = 5;
         this.numMonSelect.visible = true;
         try
         {
            this.numMonSelect["componentInspectorSetting"] = false;
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      function __setProp_gameSelect_Scene1_comboBoxes_0() : *
      {
         var _loc2_:SimpleCollectionItem = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:* = undefined;
         try
         {
            this.gameSelect["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         var _loc1_:DataProvider = new DataProvider();
         _loc3_ = [{
            "label":"AssettoCorsa (vFOV°)",
            "data":"AC"
         },{
            "label":"rFactor1 & 2, GSC, GSCE, SCE, AMS (vFOV°)",
            "data":"rf2"
         },{
            "label":"Project CARS ( hFOV°)",
            "data":"pCARS"
         },{
            "label":"RaceRoom Racing Experience ( vFOVx)",
            "data":"RRRE"
         },{
            "label":"Race 07, GTR Evo (vFOV%)",
            "data":"Race07"
         },{
            "label":"GRID Autosport, DiRT Rally (vFOV° x2)",
            "data":"GAS"
         },{
            "label":"GTR2 (vFOVx)",
            "data":"GTR2"
         },{
            "label":"Richard Burns Rally (hFOVrad)",
            "data":"RBR"
         }];
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc2_ = new SimpleCollectionItem();
            _loc4_ = _loc3_[_loc5_];
            for(_loc6_ in _loc4_)
            {
               _loc2_[_loc6_] = _loc4_[_loc6_];
            }
            _loc1_.addItem(_loc2_);
            _loc5_++;
         }
         this.gameSelect.dataProvider = _loc1_;
         this.gameSelect.editable = true;
         this.gameSelect.enabled = true;
         this.gameSelect.prompt = "Select Game";
         this.gameSelect.restrict = "";
         this.gameSelect.rowCount = 5;
         this.gameSelect.visible = true;
         try
         {
            this.gameSelect["componentInspectorSetting"] = false;
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      function __setProp_unitSelect_Scene1_comboBoxes_0() : *
      {
         var _loc2_:SimpleCollectionItem = null;
         var _loc3_:Array = null;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:* = undefined;
         try
         {
            this.unitSelect["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         var _loc1_:DataProvider = new DataProvider();
         _loc3_ = [{
            "label":"inches",
            "data":"inches"
         },{
            "label":"cm",
            "data":"cm"
         }];
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            _loc2_ = new SimpleCollectionItem();
            _loc4_ = _loc3_[_loc5_];
            for(_loc6_ in _loc4_)
            {
               _loc2_[_loc6_] = _loc4_[_loc6_];
            }
            _loc1_.addItem(_loc2_);
            _loc5_++;
         }
         this.unitSelect.dataProvider = _loc1_;
         this.unitSelect.editable = true;
         this.unitSelect.enabled = true;
         this.unitSelect.prompt = "Units";
         this.unitSelect.restrict = "";
         this.unitSelect.rowCount = 2;
         this.unitSelect.visible = true;
         try
         {
            this.unitSelect["componentInspectorSetting"] = false;
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      function __setProp_slider_Scene1_slider_0() : *
      {
         try
         {
            this.slider["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.slider.direction = "horizontal";
         this.slider.enabled = true;
         this.slider.liveDragging = true;
         this.slider.maximum = 100;
         this.slider.minimum = 19;
         this.slider.snapInterval = 1;
         this.slider.tickInterval = 2;
         this.slider.value = 24;
         this.slider.visible = true;
         try
         {
            this.slider["componentInspectorSetting"] = false;
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      function __setProp_calcButton_Scene1_calcButton_0() : *
      {
         try
         {
            this.calcButton["componentInspectorSetting"] = true;
         }
         catch(e:Error)
         {
         }
         this.calcButton.emphasized = true;
         this.calcButton.enabled = true;
         this.calcButton.label = "Calculate FOV";
         this.calcButton.labelPlacement = "right";
         this.calcButton.selected = false;
         this.calcButton.toggle = false;
         this.calcButton.visible = true;
         try
         {
            this.calcButton["componentInspectorSetting"] = false;
            return;
         }
         catch(e:Error)
         {
            return;
         }
      }
      
      function frame1() : *
      {
         this.screenShot = new Loader();
         this.topDistArrow = new Sprite();
         this.ga = this.topDistArrow.graphics;
         this.monFrame = new Sprite();
         this.mf = this.monFrame.graphics;
         this.imageLoaded = false;
         this.head.addEventListener(MouseEvent.MOUSE_DOWN,this.moveHeadStart);
         this.head.addEventListener(MouseEvent.MOUSE_UP,this.moveHeadStop);
         this.slider.addEventListener(SliderEvent.CHANGE,this.monSizeChanged);
         this.numMonSelect.addEventListener(Event.CHANGE,this.monQtyChanged);
         this.ratioSelect.addEventListener(Event.CHANGE,this.monRatioChanged);
         this.unitSelect.addEventListener(Event.CHANGE,this.distUnitChanged);
         this.gameSelect.addEventListener(Event.CHANGE,this.gameChanged);
         this.calcButton.addEventListener(MouseEvent.CLICK,this.submitted);
         this.closeFovInfo.addEventListener(MouseEvent.CLICK,this.onFovClose);
         this.donateButton.addEventListener(MouseEvent.CLICK,this.donate);
         this.init();
         this.setupFrame();
      }
   }
}
