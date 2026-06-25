import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT — PIN Gate
// ─────────────────────────────────────────────────────────────────────────────
class ParentDashboardGate extends StatefulWidget {
  const ParentDashboardGate({Key? key}) : super(key: key);
  @override
  State<ParentDashboardGate> createState() => _ParentDashboardGateState();
}

class _ParentDashboardGateState extends State<ParentDashboardGate> {
  final List<String> _entered = [];
  String? _savedPin;
  bool _isSettingPin = false;
  final List<String> _newPinBuffer = [];

  // FIX 1: renamed from _confirmBuffer_raw to _confirmBuffer (Dart lowerCamelCase)
  String _confirmBuffer = '';

  bool _error = false;
  String _errorMsg = '';

  // FIX 3: use FlutterSecureStorage instead of SharedPreferences for PIN
  static const _storage = FlutterSecureStorage();
  static const String _prefKey = 'parent_dashboard_pin';

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final pin = await _storage.read(key: _prefKey);
    setState(() {
      _savedPin = pin;
      if (_savedPin == null) _isSettingPin = true;
    });
  }

  Future<void> _savePin(String pin) async {
    await _storage.write(key: _prefKey, value: pin);
    setState(() {
      _savedPin = pin;
      _isSettingPin = false;
      _newPinBuffer.clear();
      _confirmBuffer = '';
    });
  }

  // FIX 4: navigation moved OUTSIDE setState to avoid "setState after dispose"
  void _onKey(String digit) {
    if (_isSettingPin) {
      setState(() {
        _error = false;
        if (_newPinBuffer.length < 4) {
          _newPinBuffer.add(digit);
        } else {
          _confirmBuffer += digit;
          if (_confirmBuffer.length == 4) {
            if (_confirmBuffer == _newPinBuffer.join()) {
              _savePin(_confirmBuffer);
            } else {
              _errorMsg = 'PINs do not match. Try again.';
              _error = true;
              _newPinBuffer.clear();
              _confirmBuffer = '';
            }
          }
        }
      });
    } else {
      // FIX 4: mutate state first, then navigate outside setState
      bool shouldNavigate = false;
      bool wrongPin = false;

      setState(() {
        _error = false;
        if (_entered.length < 4) {
          _entered.add(digit);
          if (_entered.length == 4) {
            if (_entered.join() == _savedPin) {
              shouldNavigate = true;
            } else {
              _errorMsg = 'Incorrect PIN. Try again.';
              _error = true;
              wrongPin = true;
              _entered.clear();
            }
          }
        }
      });

      if (shouldNavigate) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ParentDashboard()),
        );
      }
    }
  }

  // FIX 1 & 2: _onDelete now correctly checks _confirmBuffer.isNotEmpty first
  void _onDelete() {
    setState(() {
      _error = false;
      if (_isSettingPin) {
        if (_confirmBuffer.isNotEmpty) {
          // In confirm step — delete from confirm buffer
          _confirmBuffer = _confirmBuffer.substring(0, _confirmBuffer.length - 1);
        } else if (_newPinBuffer.isNotEmpty) {
          // In new-PIN step — delete from new PIN buffer
          _newPinBuffer.removeLast();
        }
      } else {
        if (_entered.isNotEmpty) _entered.removeLast();
      }
    });
  }

  // FIX 2: _dotsFilled now cleanly returns confirmBuffer length during confirm step
  int get _dotsFilled {
    if (_isSettingPin) {
      return _newPinBuffer.length < 4 ? _newPinBuffer.length : _confirmBuffer.length;
    }
    return _entered.length;
  }

  String get _headingText {
    if (_isSettingPin) {
      return _newPinBuffer.length < 4 ? 'Set Parent PIN' : 'Confirm PIN';
    }
    return 'Parent Dashboard';
  }

  String get _subText {
    if (_isSettingPin) {
      return _newPinBuffer.length < 4
          ? 'Choose a 4-digit PIN'
          : 'Enter PIN again to confirm';
    }
    return 'Enter your 4-digit PIN';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00073e),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_sharp,
                        color: Color(0xFFFFC857)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Icon(Icons.shield_outlined,
                      color: Color(0xFFFFC857), size: 28),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC857).withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFC857), width: 2),
              ),
              child: const Icon(Icons.lock_outline,
                  color: Color(0xFFFFC857), size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              _headingText,
              style: const TextStyle(
                fontSize: 26,
                fontFamily: 'Amaranth',
                color: Color(0xFFFFC857),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _subText,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'JosefinSans',
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final filled = i < _dotsFilled;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: filled ? 18 : 16,
                  height: filled ? 18 : 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        filled ? const Color(0xFFFFC857) : Colors.transparent,
                    border: Border.all(
                      color:
                          _error ? Colors.redAccent : const Color(0xFFFFC857),
                      width: 2,
                    ),
                  ),
                );
              }),
            ),
            AnimatedOpacity(
              opacity: _error ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMsg,
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                      fontFamily: 'JosefinSans'),
                ),
              ),
            ),
            const Spacer(),
            _buildNumpad(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: keys.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: row.map((k) {
                if (k.isEmpty) return const SizedBox(width: 72, height: 72);
                return GestureDetector(
                  onTap: () => k == 'del' ? _onDelete() : _onKey(k),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFC857).withOpacity(0.10),
                      border: Border.all(
                          color: const Color(0xFFFFC857).withOpacity(0.3),
                          width: 1.5),
                    ),
                    child: Center(
                      child: k == 'del'
                          ? const Icon(Icons.backspace_outlined,
                              color: Color(0xFFFFC857), size: 22)
                          : Text(
                              k,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Color(0xFFFFC857),
                                fontFamily: 'JosefinSans',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MAIN DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
class ParentDashboard extends StatefulWidget {
  const ParentDashboard({Key? key}) : super(key: key);
  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFC857),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00073e),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_sharp,
              color: Color(0xFFFFC857), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Parent Dashboard',
          style: TextStyle(
            fontFamily: 'Amaranth',
            fontSize: 22,
            color: Color(0xFFFFC857),
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.settings_outlined, color: Color(0xFFFFC857)),
            onPressed: () => _showPinReset(context),
            tooltip: 'Reset PIN',
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: const Color(0xFFFFC857),
          unselectedLabelColor: Colors.white38,
          indicatorColor: const Color(0xFFFFC857),
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontFamily: 'JosefinSans', fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Activity'),
            Tab(icon: Icon(Icons.history_rounded), text: 'History'),
            Tab(icon: Icon(Icons.timer_outlined), text: 'Time Limit'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _ActivityTab(uid: _user?.uid),
          _HistoryTab(uid: _user?.uid),
          _TimeLimitTab(uid: _user?.uid),
        ],
      ),
    );
  }

  void _showPinReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF00073e),
        title: const Text('Reset PIN',
            style: TextStyle(
                color: Color(0xFFFFC857), fontFamily: 'Amaranth')),
        content: const Text(
          'This will clear your current PIN and ask you to set a new one next time.',
          style: TextStyle(color: Colors.white70, fontFamily: 'JosefinSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              // FIX 3: delete from secure storage
              const storage = FlutterSecureStorage();
              await storage.delete(key: 'parent_dashboard_pin');
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Reset',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — Reading Activity
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityTab extends StatelessWidget {
  final String? uid;
  const _ActivityTab({this.uid});

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return _centeredMsg('Please log in to view activity.');
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reading_sessions')
          .where('uid', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];

        int totalMinutes = 0;
        int totalStories = docs.length;
        final Map<String, int> dailyMap = {};

        for (final doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final int mins = (data['duration_minutes'] ?? 0) as int;
          totalMinutes += mins;
          final ts = data['timestamp'];
          if (ts != null) {
            final dt = (ts as Timestamp).toDate();
            final key =
                '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
            dailyMap[key] = (dailyMap[key] ?? 0) + mins;
          }
        }

        final avgPerSession =
            totalStories > 0 ? (totalMinutes / totalStories).round() : 0;

        final List<_DayBar> bars = _last7Days(dailyMap);

        // FIX 5: use fold instead of reduce to avoid StateError; clamp to 1
        // to prevent division-by-zero when all bars are 0
        final int barMax =
            bars.fold(0, (prev, b) => b.minutes > prev ? b.minutes : prev);
        final int safeMax = barMax == 0 ? 1 : barMax;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  _StatCard(
                    icon: Icons.auto_stories_rounded,
                    label: 'Stories Read',
                    value: '$totalStories',
                    color: const Color(0xFF00073e),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.schedule_rounded,
                    label: 'Total Minutes',
                    value: '$totalMinutes',
                    color: const Color(0xFF181621),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    icon: Icons.trending_up_rounded,
                    label: 'Avg / Session',
                    value: '${avgPerSession}m',
                    color: const Color(0xFF00073e),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('Last 7 Days'),
              const SizedBox(height: 12),
              Container(
                decoration: _cardDecor(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: 140,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: bars.map((b) {
                          // FIX 5: use safeMax to avoid division by zero
                          final frac = b.minutes / safeMax;
                          return _Bar(
                              dayLabel: b.label,
                              fraction: frac,
                              minutes: b.minutes);
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Minutes spent reading per day',
                      style: TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                          fontFamily: 'JosefinSans'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Recent Sessions'),
              const SizedBox(height: 12),
              if (docs.isEmpty)
                _emptyCard(
                    'No sessions recorded yet.\nReading sessions will appear here automatically.')
              else
                ...docs.take(10).map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return _SessionTile(data: data);
                }),
            ],
          ),
        );
      },
    );
  }
}

List<_DayBar> _last7Days(Map<String, int> map) {
  final now = DateTime.now();
  return List.generate(7, (i) {
    final d = now.subtract(Duration(days: 6 - i));
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final labels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return _DayBar(label: labels[d.weekday % 7], minutes: map[key] ?? 0);
  });
}

class _DayBar {
  final String label;
  final int minutes;
  _DayBar({required this.label, required this.minutes});
}

class _Bar extends StatelessWidget {
  final String dayLabel;
  final double fraction;
  final int minutes;
  const _Bar(
      {required this.dayLabel,
      required this.fraction,
      required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (minutes > 0)
          Text('${minutes}m',
              style: const TextStyle(
                  fontSize: 9,
                  fontFamily: 'JosefinSans',
                  color: Color(0xFF00073e))),
        const SizedBox(height: 2),
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 28,
          height: (fraction * 100).clamp(4.0, 100.0),
          decoration: BoxDecoration(
            color: fraction > 0
                ? const Color(0xFF00073e)
                : const Color(0xFF00073e).withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(dayLabel,
            style: const TextStyle(
                fontSize: 11,
                fontFamily: 'JosefinSans',
                color: Colors.black54)),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SessionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final title = data['story_title'] ?? 'Unknown Story';
    final lang = data['language'] ?? '';
    final mins = data['duration_minutes'] ?? 0;
    final isLive = data['is_live'] == true;
    final ts = data['timestamp'];
    String dateStr = '';
    if (ts != null) {
      final dt = (ts as Timestamp).toDate();
      dateStr =
          '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecor(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF00073e),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: Color(0xFFFFC857), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'JosefinSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF181621))),
                    ),
                    if (isLive)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('LIVE',
                            style: TextStyle(
                                fontFamily: 'JosefinSans',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('$lang · $dateStr',
                    style: const TextStyle(
                        fontFamily: 'JosefinSans',
                        fontSize: 12,
                        color: Colors.black54)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF00073e),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${mins}m',
                style: const TextStyle(
                    fontFamily: 'JosefinSans',
                    fontSize: 12,
                    color: Color(0xFFFFC857))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — Stories Read History
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryTab extends StatefulWidget {
  final String? uid;
  const _HistoryTab({this.uid});
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  String _filterLang = 'All';
  final List<String> _langs = [
    'All',
    'Bengali',
    'Hindi',
    'Gujarati',
    'Telugu',
    'Marathi'
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.uid == null) {
      return _centeredMsg('Please log in to view history.');
    }
    return Column(
      children: [
        Container(
          color: const Color(0xFF00073e),
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _langs.map((lang) {
                final sel = _filterLang == lang;
                return GestureDetector(
                  onTap: () => setState(() => _filterLang = lang),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel
                          ? const Color(0xFFFFC857)
                          : Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? const Color(0xFFFFC857)
                              : Colors.white24),
                    ),
                    child: Text(lang,
                        style: TextStyle(
                            fontFamily: 'JosefinSans',
                            fontSize: 13,
                            color: sel
                                ? const Color(0xFF181621)
                                : Colors.white70)),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _buildQuery(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return _emptyCard(
                    'No stories read yet.\nStart reading to build your history!');
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  return _HistoryCard(data: data, rank: i + 1);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _buildQuery() {
    CollectionReference col =
        FirebaseFirestore.instance.collection('reading_sessions');

    if (_filterLang == 'All') {
      return col
          .where('uid', isEqualTo: widget.uid)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots();
    } else {
      // Requires composite Firestore index: uid ASC + language ASC + timestamp DESC
      return col
          .where('uid', isEqualTo: widget.uid)
          .where('language', isEqualTo: _filterLang)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .snapshots();
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final int rank;
  const _HistoryCard({required this.data, required this.rank});

  @override
  Widget build(BuildContext context) {
    final title = data['story_title'] ?? 'Unknown Story';
    final lang = data['language'] ?? '';
    final mins = data['duration_minutes'] ?? 0;
    final isLive = data['is_live'] == true;
    final ts = data['timestamp'];
    String dateStr = '';
    String timeStr = '';
    if (ts != null) {
      final dt = (ts as Timestamp).toDate();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      dateStr = '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      timeStr =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    final Color langColor = _langColor(lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecor(),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF00073e),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('$rank',
                    style: const TextStyle(
                        color: Color(0xFFFFC857),
                        fontFamily: 'JosefinSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontFamily: 'JosefinSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF181621))),
                      ),
                      if (isLive)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.green.shade600,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('LIVE',
                              style: TextStyle(
                                  fontFamily: 'JosefinSans',
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: langColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(lang,
                            style: TextStyle(
                                fontFamily: 'JosefinSans',
                                fontSize: 11,
                                color: langColor,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Text('$dateStr · $timeStr',
                          style: const TextStyle(
                              fontFamily: 'JosefinSans',
                              fontSize: 11,
                              color: Colors.black45)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.black45),
                const SizedBox(height: 2),
                Text('${mins}m',
                    style: const TextStyle(
                        fontFamily: 'JosefinSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00073e))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _langColor(String lang) {
    switch (lang) {
      case 'Bengali':
        return Colors.teal;
      case 'Hindi':
        return Colors.deepOrange;
      case 'Gujarati':
        return Colors.purple;
      case 'Telugu':
        return Colors.indigo;
      case 'Marathi':
        return Colors.green;
      default:
        return Colors.blueGrey;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — Time Limits
// ─────────────────────────────────────────────────────────────────────────────
class _TimeLimitTab extends StatefulWidget {
  final String? uid;
  const _TimeLimitTab({this.uid});
  @override
  State<_TimeLimitTab> createState() => _TimeLimitTabState();
}

class _TimeLimitTabState extends State<_TimeLimitTab> {
  int _dailyLimitMins = 30;
  bool _limitEnabled = false;
  bool _loading = true;

  static const String _prefLimit = 'parent_daily_limit_mins';
  static const String _prefEnabled = 'parent_limit_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyLimitMins = prefs.getInt(_prefLimit) ?? 30;
      _limitEnabled = prefs.getBool(_prefEnabled) ?? false;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefLimit, _dailyLimitMins);
    await prefs.setBool(_prefEnabled, _limitEnabled);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved!',
            style: TextStyle(fontFamily: 'JosefinSans')),
        backgroundColor: Color(0xFF00073e),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Stream<QuerySnapshot>? _todayStream() {
    if (widget.uid == null) return null;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    return FirebaseFirestore.instance
        .collection('reading_sessions')
        .where('uid', isEqualTo: widget.uid)
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: _todayStream(),
            builder: (context, snapshot) {
              int usedToday = 0;
              for (final doc in snapshot.data?.docs ?? []) {
                usedToday += (doc['duration_minutes'] ?? 0) as int;
              }

              final double progress = _dailyLimitMins > 0
                  ? (usedToday / _dailyLimitMins).clamp(0.0, 1.0)
                  : 0.0;
              final bool overLimit =
                  usedToday >= _dailyLimitMins && _limitEnabled;

              return Container(
                decoration: _cardDecor(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.today_rounded,
                            color: Color(0xFF00073e), size: 20),
                        const SizedBox(width: 8),
                        const Text("Today's Reading",
                            style: TextStyle(
                                fontFamily: 'JosefinSans',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF181621))),
                        const Spacer(),
                        Text(
                          '$usedToday / $_dailyLimitMins min',
                          style: TextStyle(
                              fontFamily: 'JosefinSans',
                              fontSize: 13,
                              color: overLimit
                                  ? Colors.redAccent
                                  : const Color(0xFF00073e),
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor:
                            const Color(0xFF00073e).withOpacity(0.12),
                        valueColor: AlwaysStoppedAnimation<Color>(overLimit
                            ? Colors.redAccent
                            : const Color(0xFF00073e)),
                      ),
                    ),
                    if (overLimit)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: const [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.redAccent, size: 16),
                            SizedBox(width: 6),
                            Text('Daily limit reached!',
                                style: TextStyle(
                                    fontFamily: 'JosefinSans',
                                    fontSize: 13,
                                    color: Colors.redAccent)),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _sectionTitle('Daily Time Limit'),
          const SizedBox(height: 12),
          Container(
            decoration: _cardDecor(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        color: Color(0xFF00073e), size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Enable daily reading limit',
                        style: TextStyle(
                            fontFamily: 'JosefinSans',
                            fontSize: 15,
                            color: Color(0xFF181621)),
                      ),
                    ),
                    Switch(
                      value: _limitEnabled,
                      onChanged: (v) => setState(() => _limitEnabled = v),
                      activeColor: const Color(0xFF00073e),
                      activeTrackColor: const Color(0xFFFFC857),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: _limitEnabled ? 1 : 0.4,
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Limit Duration',
                              style: TextStyle(
                                  fontFamily: 'JosefinSans',
                                  fontSize: 13,
                                  color: Colors.black54)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00073e),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_dailyLimitMins minutes',
                              style: const TextStyle(
                                  fontFamily: 'JosefinSans',
                                  color: Color(0xFFFFC857),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: const Color(0xFF00073e),
                          inactiveTrackColor:
                              const Color(0xFF00073e).withOpacity(0.15),
                          thumbColor: const Color(0xFF00073e),
                          overlayColor:
                              const Color(0xFF00073e).withOpacity(0.1),
                        ),
                        child: Slider(
                          value: _dailyLimitMins.toDouble(),
                          min: 5,
                          max: 120,
                          divisions: 23,
                          onChanged: _limitEnabled
                              ? (v) =>
                                  setState(() => _dailyLimitMins = v.round())
                              : null,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [15, 30, 45, 60].map((m) {
                          final sel = _dailyLimitMins == m;
                          return GestureDetector(
                            onTap: _limitEnabled
                                ? () => setState(() => _dailyLimitMins = m)
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: sel
                                    ? const Color(0xFF00073e)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: sel
                                      ? const Color(0xFF00073e)
                                      : Colors.black26,
                                ),
                              ),
                              child: Text('${m}m',
                                  style: TextStyle(
                                      fontFamily: 'JosefinSans',
                                      fontSize: 13,
                                      color: sel
                                          ? const Color(0xFFFFC857)
                                          : Colors.black54)),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00073e),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _saveSettings,
                    child: const Text('Save Settings',
                        style: TextStyle(
                            fontFamily: 'Amaranth',
                            fontSize: 17,
                            color: Color(0xFFFFC857))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF00073e).withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF00073e).withOpacity(0.2)),
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFF00073e), size: 18),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'When the daily limit is reached, the app will notify you. Reading sessions are tracked automatically whenever your child opens a story.',
                    style: TextStyle(
                        fontFamily: 'JosefinSans',
                        fontSize: 12,
                        color: Colors.black54,
                        height: 1.5),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _cardDecor() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF181621).withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

Widget _sectionTitle(String text) => Text(
      text,
      style: const TextStyle(
        fontFamily: 'Amaranth',
        fontSize: 18,
        color: Color(0xFF181621),
        fontWeight: FontWeight.w600,
      ),
    );

Widget _centeredMsg(String msg) => Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(msg,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'JosefinSans',
                fontSize: 15,
                color: Colors.black54)),
      ),
    );

Widget _emptyCard(String msg) => Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(28),
      decoration: _cardDecor(),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.hourglass_empty_rounded,
                color: Color(0xFF00073e), size: 40),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'JosefinSans',
                    fontSize: 14,
                    color: Colors.black45)),
          ],
        ),
      ),
    );

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFFFFC857), size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontFamily: 'JosefinSans',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFFFC857))),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'JosefinSans',
                    fontSize: 9,
                    color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SESSION TRACKER
// ─────────────────────────────────────────────────────────────────────────────
