part of 'profile.dart';

// 自定义Logo组件
class StarsLogo extends StatelessWidget {
  final double size;

  const StarsLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset(
        'assets/icon/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
