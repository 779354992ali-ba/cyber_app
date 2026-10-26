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
      title: 'Control Center App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090B10),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      ),
      home: const Login3DScreen(),
    );
  }
}

// ==================== 1. شاشة تسجيل الدخول التفاعلية ====================
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
  final TextEditingController _nameController = TextEditingController();

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
    _nameController.dispose();
    super.dispose();
  }

  void _submitAction(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال البريد الإلكتروني وكلمة المرور بدقة'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          userEmail: email,
          userName: _nameController.text.trim().isNotEmpty 
              ? _nameController.text.trim() 
              : email.split('@')[0],
        ),
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                                  Icons.security_rounded,
                                  size: 36,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              isLogin ? 'تسجيل الدخول' : 'إنشاء حساب جديد',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isLogin ? 'أدخل بياناتك للمتابعة إلى النظام' : 'املأ الحقول التالية للتسجيل',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 26),
                            if (!isLogin) ...[
                              _buildTextField(
                                controller: _nameController,
                                hint: 'الاسم الكامل',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                            ],
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
                                      isLogin ? 'دخول للنظام' : 'إتمام التسجيل',
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
                                      text: isLogin ? 'سجل الان' : 'تسجيل الدخول',
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

// ==================== 2. لوحة التحكم الرئيسية ====================
class DashboardScreen extends StatefulWidget {
  final String userEmail;
  final String userName;

  const DashboardScreen({
    super.key,
    required this.userEmail,
    required this.userName,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeTabContent(userName: widget.userName, userEmail: widget.userEmail),
      const ToolsTabContent(),
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
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
                BottomNavigationBarItem(icon: Icon(Icons.widgets_rounded), label: 'الأدوات'),
                BottomNavigationBarItem(icon: Icon(Icons.code_rounded), label: 'المحرر الذكي'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== تبويب 1: الرئيسية ====================
class HomeTabContent extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HomeTabContent({super.key, required this.userName, required this.userEmail});

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF13111C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً', style: TextStyle(color: Color(0xFFA855F7))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('أهلاً بك، $userName', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(userEmail, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6))),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Login3DScreen()));
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'الأنظمة المتصلة',
                  '12',
                  Icons.router_rounded,
                  const Color(0xFF6366F1),
                  () => _showInfoDialog(context, 'تفاصيل الأنظمة المتصلة', 'إجمالي السيرفرات والأنظمة النشطة حالياً: 12 نظام متصل بكفاءة وخوادم مستقرة.'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'المهام المنجزة',
                  '38',
                  Icons.task_alt_rounded,
                  const Color(0xFFA855F7),
                  () => _showInfoDialog(context, 'تفاصيل المهام المنجزة', 'تم إنجاز 38 مهمة بنجاح ضمن الجدول الزمني للنظام وجلسات العمل الأخيرة.'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text('سجل العمليات الحديثة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          _buildActivityItem(
            context,
            'تم مزامنة قاعدة البيانات بنجاح',
            'منذ 5 دقائق',
            Icons.cloud_done_rounded,
            Colors.green,
            () => _showInfoDialog(context, 'تفاصيل المزامنة', 'عملية مزامنة البيانات السحابية تمت بنجاح وبدون أي فقدان في الحزم.'),
          ),
          _buildActivityItem(
            context,
            'فحص الحماية والاتصالات الآمنة',
            'منذ ساعة',
            Icons.shield_rounded,
            Colors.blue,
            () => _showInfoDialog(context, 'تفاصيل الحماية', 'فحص جدار الحماية والشهادات الرقمية أثبت سلامة جميع المنافذ والاتصالات.'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
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
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String time, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
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
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

// ==================== تبويب 2: الأدوات (تفاعلية بالكامل وتفتح نوافذ تفصيلية) ====================
class ToolsTabContent extends StatefulWidget {
  const ToolsTabContent({super.key});

  @override
  State<ToolsTabContent> createState() => _ToolsTabContentState();
}

class _ToolsTabContentState extends State<ToolsTabContent> {
  bool _isServiceActive = true;
  double _sliderValue = 75.0;

  void _showToolModal(BuildContext context, String title, String description, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF13111C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 16),
            const LinearProgressIndicator(color: Color(0xFFA855F7), backgroundColor: Colors.white12),
            const SizedBox(height: 10),
            const Text('حالة الأداة: جاهزة للتشغيل والتنفيذ الفوري.', style: TextStyle(color: Colors.tealAccent, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم تنفيذ أداة ($title) بنجاح 🚀'), backgroundColor: color),
              );
            },
            child: const Text('تنفيذ الأداة', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('إدارة الخدمات والأدوات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          _buildControlCard(
            title: 'حالة النظام الأساسي',
            subtitle: _isServiceActive ? 'النظام يعمل بكفاءة عالية' : 'النظام متوقف مؤقتاً',
            child: Switch(
              value: _isServiceActive,
              activeColor: const Color(0xFFA855F7),
              onChanged: (value) => setState(() => _isServiceActive = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildControlCard(
            title: 'مستوى الأداء والموارد',
            subtitle: 'تحديد استهلاك الموارد: ${_sliderValue.toInt()}%',
            child: Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 10,
              activeColor: const Color(0xFF6366F1),
              onChanged: (value) => setState(() => _sliderValue = value),
            ),
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: 'فحص التحديثات الأمنية',
            desc: 'التحقق من حزم النظام وجدار الحماية وتحديث التوقيعات',
            icon: Icons.security_update_good_rounded,
            color: Colors.teal,
            onTap: () => _showToolModal(
              context,
              'فحص التحديثات الأمنية',
              'تقوم هذه الأداة بفحص توقيعات النظام والتأكد من عدم وجود ثغرات أمنية في الاتصالات أو السيرفرات المتصلة.',
              Icons.security_update_good_rounded,
              Colors.teal,
            ),
          ),
          _buildActionCard(
            title: 'تفريغ الذاكرة المؤقتة',
            desc: 'حذف الملفات المؤقتة لتحسين سرعة وأداء التطبيق',
            icon: Icons.cleaning_services_rounded,
            color: Colors.amber,
            onTap: () => _showToolModal(
              context,
              'تفريغ الذاكرة المؤقتة',
              'سيتم مسح الملفات المؤقتة والبيانات المخبأة لإتاحة مساحة أكبر وتحسين استجابة التطبيق بشكل ملحوظ.',
              Icons.cleaning_services_rounded,
              Colors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard({required String title, required String subtitle, required Widget child}) {
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white60)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildActionCard({required String title, required String desc, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

// ==================== تبويب 3: المحرر الذكي ومحاكي التنفيذ ====================
class CodeEditorTabContent extends StatefulWidget {
  const CodeEditorTabContent({super.key});

  @override
  State<CodeEditorTabContent> createState() => _CodeEditorTabContentState();
}

class _CodeEditorTabContentState extends State<CodeEditorTabContent> {
  final TextEditingController _codeController = TextEditingController(
    text: 'void main() {\n  print("Hello from Control Center Execution Engine!");\n}',
  );
  String selectedLanguage = 'Dart';
  List<String> _analysisResults = [];
  String _executionOutput = '';

  void _analyzeCode() {
    final code = _codeController.text;
    List<String> issues = [];
    if (!code.contains('main')) {
      issues.add('⚠️ تنبيه: الدالة الرئيسية main() غير موجودة.');
    } else {
      issues.add('✅ الكود سليم وخالٍ من الأخطاء النحوية الأساسية.');
    }
    setState(() => _analysisResults = issues);
  }

  void _runScript() {
    final code = _codeController.text;
    setState(() {
      _executionOutput = '> جاري ترجمة وتنفيذ سكربت ($selectedLanguage)...\n';
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (code.contains('print')) {
        RegExp regExp = RegExp(r'print\s*\(\s*["\']([^"\']*)["\']\s*\)');
        Match? match = regExp.firstMatch(code);
        if (match != null) {
          setState(() {
            _executionOutput += '✔ تم التنفيذ بنجاح.\n[Output]: ${match.group(1)}';
          });
        } else {
          setState(() {
            _executionOutput += '✔ تم تنفيذ السكربت بنجاح بدون مخرجات نصية.';
          });
        }
      } else {
        setState(() {
          _executionOutput += '✔ تم تشغيل السكربت بنجاح.';
        });
      }
    });
  }

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
                const Text('المحرر الذكي ومحاكي التنفيذ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                DropdownButton<String>(
                  value: selectedLanguage,
                  dropdownColor: const Color(0xFF13111C),
                  style: const TextStyle(color: Colors.white),
                  items: ['Dart', 'Python', 'JavaScript'].map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                  onChanged: (val) => setState(() => selectedLanguage = val!),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _analyzeCode,
                  icon: const Icon(Icons.analytics, size: 16),
                  label: const Text('فحص الأخطاء'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _runScript,
                  icon: const Icon(Icons.play_arrow, size: 16),
                  label: const Text('تشغيل السكربت'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 13),
                  decoration: const InputDecoration(border: InputBorder.none, hintText: 'اكتب الكود هنا...'),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF040608),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _executionOutput.isEmpty 
                        ? (_analysisResults.isEmpty ? 'جاهز للتنفيذ والتحليل...' : _analysisResults.join('\n'))
                        : _executionOutput,
                    style: const TextStyle(color: Colors.lightGreenAccent, fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== رسم الخلفية ====================
class Background3DPainter extends CustomPainter {
  final double animationValue;
  Background3DPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final offset1 = Offset(size.width * 0.2 + math.sin(animationValue * 2 * math.pi) * 40, size.height * 0.2);
    paint.shader = RadialGradient(colors: [const Color(0xFF6366F1).withOpacity(0.4), Colors.transparent]).createShader(Rect.fromCircle(center: offset1, radius: 200));
    canvas.drawCircle(offset1, 200, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}