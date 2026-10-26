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

// ==================== 2. لوحة التحكم الرئيسية (إدارة التبويبات) ====================
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
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.widgets_rounded),
                  label: 'الأدوات',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.code_rounded),
                  label: 'المحرر الذكي',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== تبويب 1: لوحة البيانات الرئيسية ====================
class HomeTabContent extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HomeTabContent({
    super.key,
    required this.userName,
    required this.userEmail,
  });

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
                  Text(
                    'أهلاً بك، $userName',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login3DScreen()),
                  );
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
                  'الأنظمة المتصلة',
                  '12',
                  Icons.router_rounded,
                  const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'المهام المنجزة',
                  '38',
                  Icons.task_alt_rounded,
                  const Color(0xFFA855F7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'سجل العمليات الحديثة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'تم مزامنة قاعدة البيانات بنجاح',
            'منذ 5 دقائق',
            Icons.cloud_done_rounded,
            Colors.green,
          ),
          _buildActivityItem(
            'فحص الحماية والاتصالات الآمنة',
            'منذ ساعة',
            Icons.shield_rounded,
            Colors.blue,
          ),
          _buildActivityItem(
            'تحديث إعدادات جدار الحماية',
            'منذ 3 ساعات',
            Icons.settings_suggest_rounded,
            Colors.purple,
          ),
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
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white60,
            ),
          ),
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
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.56),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== تبويب 2: إدارة الأدوات والخدمات ====================
class ToolsTabContent extends StatefulWidget {
  const ToolsTabContent({super.key});

  @override
  State<ToolsTabContent> createState() => _ToolsTabContentState();
}

class _ToolsTabContentState extends State<ToolsTabContent> {
  bool _isServiceActive = true;
  double _sliderValue = 75.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'إدارة الخدمات والأدوات',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildControlCard(
            title: 'حالة النظام الأساسي',
            subtitle: _isServiceActive ? 'النظام يعمل بكفاءة عالية' : 'النظام متوقف مؤقتاً',
            child: Switch(
              value: _isServiceActive,
              activeColor: const Color(0xFFA855F7),
              onChanged: (value) {
                setState(() {
                  _isServiceActive = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(value ? 'تم تفعيل الخدمة بنجاح' : 'تم إيقاف الخدمة مؤقتاً'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildControlCard(
            title: 'مستوى الأداء والموارد',
            subtitle: 'تحديد الحد الأقصى لاستهلاك الموارد: ${_sliderValue.toInt()}%',
            child: Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 10,
              activeColor: const Color(0xFF6366F1),
              inactiveColor: Colors.white12,
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildToolActionCard(
            title: 'فحص التحديثات الأمنية',
            desc: 'التحقق من حزم النظام وجدار الحماية وتحديث التوقيعات',
            icon: Icons.security_update_good_rounded,
            color: Colors.teal,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('النظام محدث بالكامل لأحدث إصدار')),
              );
            },
          ),
          _buildToolActionCard(
            title: 'تفريغ الذاكرة المؤقتة',
            desc: 'حذف الملفات المؤقتة لتحسين سرعة وأداء التطبيق',
            icon: Icons.cleaning_services_rounded,
            color: Colors.amber,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم تنظيف الذاكرة المؤقتة بنجاح')),
              );
            },
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

  Widget _buildToolActionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white60)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}

// ==================== تبويب 3: محرر الأكواد والتحليل الذكي للأخطاء ====================
class CodeEditorTabContent extends StatefulWidget {
  const CodeEditorTabContent({super.key});

  @override
  State<CodeEditorTabContent> createState() => _CodeEditorTabContentState();
}

class _CodeEditorTabContentState extends State<CodeEditorTabContent> {
  final TextEditingController _codeController = TextEditingController(
    text: 'void main() {\n  print("Control Center Script Executed Successfully");\n  // جرب كتابة كود ناقص فاصلة منقوطة لاختبار المحلل\n}',
  );
  String selectedLanguage = 'Dart';
  List<String> _analysisResults = [];
  bool _isAnalyzing = false;

  void _analyzeAndFormatCode() {
    setState(() {
      _isAnalyzing = true;
      _analysisResults.clear();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      final code = _codeController.text;
      List<String> issues = [];

      int openBraces = '\{'.allMatches(code).length;
      int closeBraces = '\}'.allMatches(code).length;
      if (openBraces != closeBraces) {
        issues.add('⚠️ خطأ في الأقواس: عدم تطابق أقواس البداية ({) والنهاية (}).');
      }

      if (selectedLanguage != 'Python' && code.contains('print') && !code.contains(';')) {
        issues.add('💡 اقتراح تصحيح: يبدو أنك نسيت وضع الفاصلة المنقوطة (;) في نهاية السطر البرمجي.');
      }

      if (code.contains('var ') && !code.contains('=')) {
        issues.add('⚠️ تنبيه: تم الإعلان عن متغير دون تعيين قيمة أولية له.');
      }

      if (issues.isEmpty) {
        issues.add('✅ الكود سليم تماماً ومنسق، ولا توجد أخطاء ظاهرة.');
      }

      setState(() {
        _isAnalyzing = false;
        _analysisResults = issues;
      });
    });
  }

  void _formatCode() {
    String currentText = _codeController.text;
    List<String> lines = currentText.split('\n');
    String formatted = lines.map((line) => line.trim()).join('\n');
    
    setState(() {
      _codeController.text = formatted;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✨ تم تنسيق وترتيب الكود بنجاح'),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 1),
      ),
    );
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
                const Text(
                  'المحرر الذكي والمحلل',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                DropdownButton<String>(
                  value: selectedLanguage,
                  dropdownColor: const Color(0xFF13111C),
                  style: const TextStyle(color: Colors.white),
                  items: ['Dart', 'Python', 'JavaScript', 'JSON'].map((String lang) {
                    return DropdownMenuItem<String>(value: lang, child: Text(lang));
                  }).toList(),
                  onChanged: (newValue) => setState(() => selectedLanguage = newValue!),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _formatCode,
                    icon: const Icon(Icons.format_align_left_rounded, size: 18, color: Color(0xFFA855F7)),
                    label: const Text('تنسيق تلقائي', style: TextStyle(color: Colors.white, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : _analyzeAndFormatCode,
                    icon: _isAnalyzing 
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.analytics_rounded, size: 18, color: Color(0xFF6366F1)),
                    label: Text(_isAnalyzing ? 'جاري التحليل...' : 'فحص الأخطاء', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: TextField(
                  controller: _codeController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'اكتب الكود هنا...',
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_analysisResults.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🔍 تقرير التحليل واقتراحات الحلول:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFA855F7)),
                    ),
                    const SizedBox(height: 6),
                    ..._analysisResults.map((result) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        result,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تنفيذ السكربت البرمجي بنجاح 🚀'),
                      backgroundColor: Color(0xFF6366F1),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                label: const Text(
                  'تشغيل السكربت',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
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

// ==================== رسم الخلفية التفاعلية 3D ====================
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