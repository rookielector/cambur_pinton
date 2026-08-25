import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/repositories/harmony_repository_impl.dart';
import '../../domain/repositories/harmony_repository.dart';
import '../providers/chord_identifier_provider.dart';
import '../providers/harmony_search_provider.dart';
import 'tab_chord_identifier_screen.dart';
import 'tab_credits_screen.dart';
import 'tab_harmony_search_screen.dart';

class MainScaffoldScreen extends StatefulWidget {
  const MainScaffoldScreen({super.key});

  @override
  State<MainScaffoldScreen> createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  late final HarmonyRepository _repository;
  late final HarmonySearchProvider _harmonyProvider;
  late final ChordIdentifierProvider _identifierProvider;

  bool _isLoading = true;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _repository = HarmonyRepositoryImpl();
    _harmonyProvider = HarmonySearchProvider(_repository);
    _identifierProvider = ChordIdentifierProvider(_repository);

    _initData();
  }

  Future<void> _initData() async {
    await _repository.initialize();
    _harmonyProvider.init();
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryAmber),
              SizedBox(height: 16),
              Text(
                'Cargando acordes y armonías...',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.width > 700;

    return ListenableBuilder(
      listenable: Listenable.merge([_harmonyProvider, _identifierProvider]),
      builder: (context, _) {
        return Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: isWide
                ? AppBar(
                    backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.85),
                    elevation: 0,
                    centerTitle: true,
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // App Logo Thumbnail
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryAmber, width: 1.2),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.music_note,
                                color: AppColors.primaryAmber,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.appName,
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              AppStrings.appSubtitle,
                              style: TextStyle(
                                color: AppColors.accentGold,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : null,
            body: isWide
                ? Row(
                    children: [
                      NavigationRail(
                        backgroundColor: AppColors.backgroundCard,
                        selectedIndex: _currentTabIndex,
                        onDestinationSelected: (index) {
                          setState(() {
                            _currentTabIndex = index;
                          });
                        },
                        selectedIconTheme: const IconThemeData(color: AppColors.primaryAmber),
                        unselectedIconTheme: const IconThemeData(color: AppColors.textMuted),
                        selectedLabelTextStyle: const TextStyle(
                          color: AppColors.primaryAmber,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelTextStyle: const TextStyle(color: AppColors.textMuted),
                        labelType: NavigationRailLabelType.all,
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.grid_on),
                            label: Text(AppStrings.tabHarmonySearch),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.touch_app),
                            label: Text(AppStrings.tabChordIdentifier),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.workspace_premium),
                            label: Text(AppStrings.tabCredits),
                          ),
                        ],
                      ),
                      const VerticalDivider(thickness: 1, width: 1, color: AppColors.cardBorder),
                      Expanded(
                        child: IndexedStack(
                          index: _currentTabIndex,
                          children: [
                            TabHarmonySearchScreen(provider: _harmonyProvider),
                            TabChordIdentifierScreen(provider: _identifierProvider),
                            const TabCreditsScreen(),
                          ],
                        ),
                      ),
                    ],
                  )
                : (_currentTabIndex == 2
                    ? const TabCreditsScreen()
                    : IndexedStack(
                        index: _currentTabIndex,
                        children: [
                          TabHarmonySearchScreen(provider: _harmonyProvider),
                          TabChordIdentifierScreen(provider: _identifierProvider),
                          const TabCreditsScreen(),
                        ],
                      )),
            bottomNavigationBar: isWide
                ? null
                : BottomNavigationBar(
                    backgroundColor: AppColors.backgroundDark,
                    currentIndex: _currentTabIndex,
                    selectedItemColor: AppColors.primaryAmber,
                    unselectedItemColor: AppColors.textMuted,
                    onTap: (index) {
                      setState(() {
                        _currentTabIndex = index;
                      });
                    },
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.grid_on),
                        label: AppStrings.tabHarmonySearch,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.touch_app),
                        label: AppStrings.tabChordIdentifier,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.workspace_premium),
                        label: AppStrings.tabCredits,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
