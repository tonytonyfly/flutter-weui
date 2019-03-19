import 'package:flutter/material.dart';
import '../utils.dart';
import './info.dart';
import './toast.dart';
import '../animation/rotating.dart';
import '../icon/index.dart';
import '../theme/index.dart';

// 对齐方式
enum WeToastInfoAlign {
  // 上对齐
  top,
  // 居中
  center,
  // 下对齐
  bottom
}

// loading icon
final Widget _loadingIcon = Image.asset('assets/images/loading.png', height: 42.0, package: 'weui');
// success icon
const Widget _successIcon = Icon(WeIcons.hook, color: Colors.white, size: 49.0);
// fail icon
const Widget _failIcon = Icon(WeIcons.info, color: Colors.white, size: 49.0);
// 对齐方式
final List<String> _weToastAlign = ['top', 'center', 'bottom'];

// info
typedef _info = Function(dynamic message, { int duration, WeToastInfoAlign align, double distance });
// loading
typedef _loading = Function({ dynamic message, int duration, bool mask, Widget icon });
// success
typedef _success = Function({ dynamic message, int duration, bool mask, Widget icon });
// fail
typedef _fail = Function({ dynamic message, int duration, bool mask, Widget icon });
// toast
typedef _toast = Function({ dynamic message, int duration, bool mask, Widget icon });
// loading close
typedef _close = Function();

class WeToast {
  // 信息提示
  static _info info(BuildContext context) {
    return (message, { duration, align, distance = 100.0 }) async {
      final WeConfig config = WeUi.getConfig(context);
      // 转换
      final Widget messageWidget = toTextWidget(message, 'message');
      final remove = createOverlayEntry(
        context: context,
        child: InfoWidget(
          messageWidget,
          align: _weToastAlign[config.toastInfoAlign.index],
          distance: distance
        )
      );

      // 自动关闭
      await Future.delayed(Duration(milliseconds: duration == null ? config.toastInfoDuration : duration));
      remove();
    };
  }

  // 加载中
  static _loading loading(BuildContext context) {
    _close show({ message, duration, mask = true, icon }) {
      final int toastLoadingDuration = WeUi.getConfig(context).toastLoadingDuration;

      return WeToast.toast(context)(
        icon: Rotating(icon == null ? _loadingIcon : icon, duration: 800),
        mask: mask,
        message: message,
        duration: duration == null ? toastLoadingDuration : duration
      );
    }

    return show;
  }

  // 成功
  static _success success(BuildContext context) {
    return ({ message, duration, mask = true, icon = _successIcon }) {
      final int toastSuccessDuration = WeUi.getConfig(context).toastSuccessDuration;
      WeToast.toast(context)(
        icon: icon,
        mask: mask,
        message: message,
        duration: duration == null ? toastSuccessDuration : duration
      );
    };
  }

  // 失败
  static _fail fail(BuildContext context) {
    return ({ message, duration, mask = true, icon = _failIcon }) {
      final int notifySuccessDuration = WeUi.getConfig(context).notifySuccessDuration;
      WeToast.toast(context)(
        icon: icon,
        mask: mask,
        message: message,
        duration: duration == null ? notifySuccessDuration : duration
      );
    };
  }

  // 提示
  static _toast toast(BuildContext context) {
    return ({ message, duration, mask = true, icon }) {
      // 转换
      final Widget messageWidget = toTextWidget(message, 'message');
      final remove = createOverlayEntry(
        context: context,
        child: ToastWidget(
          message: messageWidget,
          mask: mask,
          icon: icon
        )
      );

      void close() {
        remove();
      }

      // 自动关闭
      if (duration != null) {
        Future.delayed(Duration(milliseconds: duration), close);
      }

      return close;
    };
  }
}
