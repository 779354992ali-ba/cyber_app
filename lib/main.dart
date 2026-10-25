import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cyber Dashboard App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090B10),
      ),
      home: const Login3DScreen(),
    );
  }
}

// ==================== 1. شاشة تسجيل الدخول ====================
class Login3DScreen extends StatefulWidget {
  const Login3DScreen({super.key});

  @override
  State<Login3DScreen> createState() => _Login3DScreenState();
}

class _Login3DScreenState extends State<Login3DScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _pulseController;
  bool isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  double _tiltX = 0;
  double _tiltY = 0;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitAction(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال البريد الإلكتروني وكلمة المرور'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    // الانتقال مباشرة إلى لوحة التحكم الرئيسية المتكاملة
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _tiltX += details.delta.dy * 0.005;
            _tiltY -= details.delta.dx * 0.005;
            _tiltX = _tiltX.clamp(-0.3, 0.3);
            _tiltY = _tiltY.clamp(-0.3, 0.3);
          });
        },
        onPanEnd: (details) {
          setState(() {
            _tiltX = 0;
            _tiltY = 0;
          });
        },
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: Background3DPainter(_bgController.value),
                );
              },
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_tiltX)
                    ..rotateY(_tiltY),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: size.width > 450 ? 400 : size.width * 0.9,
                        padding: const EdgeInsets.all(28.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_pulseController.value * 0.1),
                                  child: child,
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withOpacity(0.6),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  size: 36,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              isLogin ? 'مرحباً بك مجدداً' : 'حساب جديد',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isLogin ? 'قم بتسجيل الدخول للمتابعة' : 'أنشئ حسابك للبدء معنا',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 30),
                            _buildTextField(
                              controller: _emailController,
                              hint: 'البريد الإلكتروني',
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller: _passwordController,
                              hint: 'كلمة المرور',
                              icon: Icons.lock_outline,
                              isPassword: true,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => _submitAction(context),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 8,
                                  shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isLogin = !isLogin;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: isLogin ? 'ليس لديك حساب؟ ' : 'لديك حساب بالفعل؟ ',
                                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  children: [
                                    TextSpan(
                                      text: isLogin ? 'إنشاء حساب' : 'تسجيل الدخول',
                                      style: const TextStyle(
                                        color: Color(0xFFA855F7),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        textAlign: TextAlign.right,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          prefixIcon: Icon(icon, color: const Color(0xFFA855F7)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

// ==================== 2. الشاشة الرئيسية والتبويبات ====================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeTabContent(),
      const ProjectsTabContent(),
      const CodeEditorTabContent(),
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF090B10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF090B10), Color(0xFF13111C)],
          ),
        ),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.transparent,
              selectedItemColor: const Color(0xFFA855F7),
              unselectedItemColor: Colors.white.withOpacity(0.4),
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'لوحة التحكم'),
                BottomNavigationBarItem(icon: Icon(Icons.apps_rounded), label: 'الأدوات'),
                BottomNavigationBarItem(icon: Icon(Icons.code_rounded), label: 'محرر الأكواد'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// تبويب 1: لوحة التحكم
class HomeTabContent extends StatelessWidget {
  const HomeTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مرحباً بك، المبرمج', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('إليك نظرة عامة على نشاطك اليوم', style: TextStyle(fontSize: 14, color: Colors.white60)),
                ],
              ),
              CircleAvatar(backgroundColor: Color(0xFF6366F1), child: Icon(Icons.person, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildStatCard('المشاريع النشطة', '4', Icons.folder_special, const Color(0xFF6366F1))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('المهام المكتملة', '18', Icons.task_alt, const Color(0xFFA855F7))),
            ],
          ),
          const SizedBox(height: 24),
          const Text('آخر النشاطات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          _buildActivityItem('تم إطلاق واجهة الـ 3D بنجاح', 'منذ ساعة', Icons.check_circle, Colors.green),
          _buildActivityItem('تحديث محرر الأكواد الشامل', 'منذ 3 ساعات', Icons.update, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(time, style: TextStyle(color: Colors.white.withOpacity(0.56), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// تبويب 2: الأدوات والمشاريع
class ProjectsTabContent extends StatelessWidget {
  const ProjectsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('مشاريعي وأدواتي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          _buildProjectCard('Bisho Top Platform', 'تطبيق ترفيهي اجتماعي متكامل', Icons.phone_android, const Color(0xFF6366F1)),
          _buildProjectCard('Cyber 3D Login', 'واجهة دخول زجاجية مستقبلية', Icons.lock, const Color(0xFFA855F7)),
          _buildProjectCard('Universal Code Editor', 'محرر أكواد يدعم لغات متعددة', Icons.code, Colors.teal),
        ],
      ),
    );
  }

  Widget _buildProjectCard(String title, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(15)),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(fontSize: 13, color: Colors.white60)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// تبويب 3: محرر الأكواد
class CodeEditorTabContent extends StatefulWidget {
  const CodeEditorTabContent({super.key});

  @override
  State<CodeEditorTabContent> createState() => _CodeEditorTabContentState();
}

class _CodeEditorTabContentState extends State<CodeEditorTabContent> {
  final TextEditingController _codeController = TextEditingController(
    text: 'void main() {\n  print("Hello from Universal Code Editor!");\n}',
  );
  String selectedLanguage = 'Dart';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('محرر الأكواد الذكي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                DropdownButton<String>(
                  value: selectedLanguage,
                  dropdownColor: const Color(0xFF13111C),
                  style: const TextStyle(color: Colors.white),
                  items: ['Dart', 'Python', 'JavaScript', 'C++'].map((String lang) {
                    return DropdownMenuItem<String>(value: lang, child: Text(lang));
                  }).toList(),
                  onChanged: (newValue) => setState(() => selectedLanguage = newValue!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 14),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'اكتب الكود هنا...'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تنفيذ الكود بنجاح 🚀'), backgroundColor: Color(0xFF6366F1)),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text('تشغيل الكود', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// خلفية 3D
class Background3DPainter extends CustomPainter {
  final double animationValue;
  Background3DPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final offset1 = Offset(
      size.width * 0.2 + math.sin(animationValue * 2 * math.pi) * 40,
      size.height * 0.2 + math.cos(animationValue * 2 * math.pi) * 40,
    );
    paint.shader = RadialGradient(
      colors: [const Color(0xFF6366F1).withOpacity(0.5), Colors.transparent],
    ).createShader(Rect.fromCircle(center: offset1, radius: 200));
    canvas.drawCircle(offset1, 200, paint);

    final offset2 = Offset(
      size.width * 0.8 + math.cos(animationValue * 2 * math.pi) * 50,
      size.height * 0.8 + math.sin(animationValue * 2 * math.pi) * 50,
    );
    paint.shader = RadialGradient(
      colors: [const Color(0xFFA855F7).withOpacity(0.4), Colors.transparent],
    ).createShader(Rect.fromCircle(center: offset2, radius: 250));
    canvas.drawCircle(offset2, 250, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
