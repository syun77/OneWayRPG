package jp_2dgames.lib;

import flixel.input.keyboard.FlxKey;
import flixel.FlxG;

/**
 * 入力モード
 **/
private enum KeyMode {
  Press;
  On;
  Release;
}

private class InputKey {

  static inline var WASD_ENABLE:Bool = false;

  public var A(get, never):Bool;
  public var B(get, never):Bool;
  public var X(get, never):Bool;
  public var Y(get, never):Bool;
  public var LEFT(get, never):Bool;
  public var UP(get, never):Bool;
  public var RIGHT(get, never):Bool;
  public var DOWN(get, never):Bool;

  var _mode:KeyMode;

  public function new(mode:KeyMode) {
    _mode = mode;
  }

  function get_A() {
    var keys = [FlxKey.Z];
    if(_checkKeys(keys)) {
      return true;
    }
#if desktop
    switch(_mode) {
      case KeyMode.Press:
        if(FlxG.mouse.justPressed) {
          return true;
        }
      case KeyMode.On:
        if(FlxG.mouse.pressed) {
          return true;
        }
      case KeyMode.Release:
        if(FlxG.mouse.justReleased) {
          return true;
        }
    }
#end
    return false;
  }
  function get_B() {
    var keys = [FlxKey.X];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_X() {
    var keys = [FlxKey.C];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_Y() {
    var keys = [FlxKey.V];
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_LEFT() {
    var keys = [FlxKey.LEFT];
    if(WASD_ENABLE) {
      keys.push(FlxKey.A);
    }
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_UP() {
    var keys = [FlxKey.UP];
    if(WASD_ENABLE) {
      keys.push(FlxKey.W);
    }
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_RIGHT() {
    var keys = [FlxKey.RIGHT];
    if(WASD_ENABLE) {
      keys.push(FlxKey.D);
    }
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }
  function get_DOWN() {
    var keys = [FlxKey.DOWN];
    if(WASD_ENABLE) {
      keys.push(FlxKey.S);
    }
    if(_checkKeys(keys)) {
      return true;
    }
    return false;
  }

  function _checkKeys(keys:Array<FlxKey>):Bool {

#if desktop
    switch(_mode) {
      case KeyMode.Press:
        if(FlxG.keys.anyJustPressed(keys)) {
          return true;
        }
      case KeyMode.On:
        if(FlxG.keys.anyPressed(keys)) {
          return true;
        }
      case KeyMode.Release:
        if(FlxG.keys.anyJustReleased(keys)) {
          return true;
        }
    }
#end
    return false;
  }

}

private class InputMouse {
  public var x(get, never):Float;
  public var y(get, never):Float;

  /**
   * コンストラクタ
   **/
  public function new() {
  }

  function get_x() {
#if desktop
    return FlxG.mouse.x;
#else
    return 0;
#end
  }
  function get_y() {
#if desktop
    return FlxG.mouse.y;
#else
    return 0;
#end
  }
}

/**
 * 入力管理
 **/
class Input {

  public static var x(get, never):Float;
  public static var y(get, never):Float;

  public static var mouse:InputMouse = new InputMouse();
  public static var press:InputKey = new InputKey(KeyMode.Press);
  public static var on:InputKey = new InputKey(KeyMode.On);
  public static var release:InputKey = new InputKey(KeyMode.Release);

  // ------------------------------------------------------
  // ■アクセサ
  static function get_x() {
    return mouse.x;
  }
  static function get_y() {
    return mouse.y;
  }
}
