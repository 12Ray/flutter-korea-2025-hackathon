import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  runApp(const ProviderScope(child: MetaNoteApp()));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<HackathonProject> _projects = [
    HackathonProject(
      title: '스마트 시티 솔루션',
      description: 'IoT와 AI를 활용한 도시 문제 해결 앱',
      category: 'IoT/AI',
      teamSize: 4,
      status: '진행중',
    ),
    HackathonProject(
      title: '친환경 라이프스타일',
      description: '개인의 탄소 발자국을 추적하고 개선하는 앱',
      category: '환경',
      teamSize: 3,
      status: '모집중',
    ),
    HackathonProject(
      title: '교육용 AR/VR',
      description: '몰입형 학습 경험을 제공하는 교육 플랫폼',
      category: '교육',
      teamSize: 5,
      status: '완료',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          '🇰🇷 한국 해커톤',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _selectedIndex == 0 ? _buildProjectList() : _buildMyProfile(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.code), label: '프로젝트'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProject,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProjectList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '진행 중인 프로젝트',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _projects.length,
              itemBuilder: (context, index) {
                return ProjectCard(project: _projects[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyProfile() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
          SizedBox(height: 16),
          Text(
            '개발자 김민규',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Flutter 개발자'),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('참여 통계', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('총 참여 해커톤: 5회'),
                  Text('완성한 프로젝트: 3개'),
                  Text('수상 경력: 1회'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewProject() {
    setState(() {
      _projects.add(
        HackathonProject(
          title: '새 프로젝트',
          description: '새로운 아이디어를 구현할 프로젝트',
          category: '기타',
          teamSize: 1,
          status: '기획중',
        ),
      );
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('새 프로젝트가 추가되었습니다!')));
  }
}

class HackathonProject {
  final String title;
  final String description;
  final String category;
  final int teamSize;
  final String status;

  HackathonProject({
    required this.title,
    required this.description,
    required this.category,
    required this.teamSize,
    required this.status,
  });
}

class ProjectCard extends StatelessWidget {
  final HackathonProject project;

  const ProjectCard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(project.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    project.status,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.category, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(project.category),
                const SizedBox(width: 16),
                Icon(Icons.group, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${project.teamSize}명'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '진행중':
        return Colors.green;
      case '모집중':
        return Colors.orange;
      case '완료':
        return Colors.blue;
      case '기획중':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
