import 'package:flutter/material.dart';
import 'package:nutrisight/views/screen/education/education_screen.dart';
import 'package:nutrisight/views/screen/history/history_screen.dart';
import 'package:nutrisight/views/screen/product/home_screen.dart';
import 'package:nutrisight/views/screen/profile/profile_screen.dart';
import 'package:nutrisight/views/screen/scanner/scan_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedPageIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    EducationScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onNavTapped(int navIndex) {
    if (navIndex == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanScreen()),
      );
      return;
    }

    final int mappedPageIndex = navIndex > 2 ? navIndex - 1 : navIndex;

    setState(() {
      _selectedPageIndex = mappedPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: _selectedPageIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                spreadRadius: 1,
                blurRadius: 12,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: SizedBox(
              height: 85,
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0,
                currentIndex: _selectedPageIndex >= 2
                    ? _selectedPageIndex + 1
                    : _selectedPageIndex,
                onTap: _onNavTapped,
                selectedItemColor: const Color(0xFF1C69A8),
                unselectedItemColor: Colors.grey.shade400,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_filled),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.school_rounded),
                    label: 'Education',
                  ),

                  BottomNavigationBarItem(
                    label: '',
                    icon: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C69A8),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1C69A8).withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),

                  const BottomNavigationBarItem(
                    icon: Icon(Icons.history_rounded),
                    label: 'History',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
