part of 'main.dart';

class ProductModeEntryScreen extends StatelessWidget {
  const ProductModeEntryScreen({
    required this.questionBank,
    this.ownerUid,
    super.key,
  });

  final QuestionBank questionBank;
  final String? ownerUid;

  void _openBilgiYarismasi(BuildContext context) {
    Navigator.of(context).push(
      TelemetryPageRoute<void>(
        screenName: 'bilgi_yarismasi_home',
        builder: (_) => HomeScreen(questionBank: questionBank),
      ),
    );
  }

  void _openWordHunt(BuildContext context) {
    Navigator.of(context).push(
      TelemetryPageRoute<void>(
        screenName: 'word_hunt_home',
        builder: (_) => WordHuntProductionEntryScreen(ownerUid: ownerUid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('product_mode_entry_screen'),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color(0xFF170C21),
              Color(0xFF352044),
              Color(0xFF0D5260),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 620;
              final cards = <Widget>[
                _ProductModeCard(
                  key: const Key('product_mode_bilgi_yarismasi'),
                  icon: Icons.quiz_rounded,
                  title: 'BİLGİ YARIŞMASI',
                  description:
                      'Bilgi Rotası tahta oyunu, günlük görevler, kariyer '
                      've diğer bilgi yarışması modları.',
                  onTap: () => _openBilgiYarismasi(context),
                ),
                _ProductModeCard(
                  key: const Key('product_mode_kelime_avi'),
                  icon: Icons.search_rounded,
                  title: 'KELİME AVI',
                  description:
                      'Rotalarda kelimeleri bul, yıldızlarını ve '
                      'ilerlemeni takip et.',
                  onTap: () => _openWordHunt(context),
                ),
              ];

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 860),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Center(
                          child: Image.asset(
                            'assets/branding/splash_logo.png',
                            key: const Key('product_mode_main_logo'),
                            width: 112,
                            height: 112,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bilgi Rotası & Kelime Avı',
                          key: Key('product_mode_brand_title'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Oynamak istediğin alanı seç.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFD7F6F2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 28),
                        if (horizontal)
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(child: cards[0]),
                                const SizedBox(width: 16),
                                Expanded(child: cards[1]),
                              ],
                            ),
                          )
                        else ...<Widget>[
                          cards[0],
                          const SizedBox(height: 16),
                          cards[1],
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ProductModeCard extends StatelessWidget {
  const _ProductModeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          constraints: const BoxConstraints(minHeight: 188),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0x18FFFFFF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x55FFFFFF)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: const Color(0xFFFFE082), size: 46),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFE7E1F0),
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
