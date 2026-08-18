/// Portfolio data.
///
/// Swapping in real work later is a two-step job: drop the photograph into
/// `assets/images/` and change the `image` path below. Nothing in the UI
/// hard-codes a project.
class Project {
  const Project({
    required this.name,
    required this.category,
    required this.image,
    this.location,
    this.year,
  });

  final String name;
  final String category;
  final String image;
  final String? location;
  final String? year;

  /// "Residential Interior · Kochi"
  String get meta =>
      location == null ? category : '$category  ·  $location';
}

const List<Project> kProjects = <Project>[
  Project(
    name: 'Modern Residence',
    category: 'Residential Interior',
    location: 'Kochi',
    year: '2025',
    image: 'assets/images/project-01.jpg',
  ),
  Project(
    name: 'Contemporary Living',
    category: 'Residential Interior',
    location: 'Kakkanad',
    year: '2025',
    image: 'assets/images/project-02.jpg',
  ),
  Project(
    name: 'Minimal Workspace',
    category: 'Commercial Interior',
    location: 'Kochi',
    year: '2024',
    image: 'assets/images/project-03.jpg',
  ),
  Project(
    name: 'Quiet Hours',
    category: 'Residential Interior',
    location: 'Panampilly Nagar',
    year: '2024',
    image: 'assets/images/project-04.jpg',
  ),
  Project(
    name: 'The Open Kitchen',
    category: 'Residential Interior',
    location: 'Kakkanad',
    year: '2024',
    image: 'assets/images/project-05.jpg',
  ),
  Project(
    name: 'Stone & Light',
    category: 'Residential Interior',
    location: 'Edappally',
    year: '2023',
    image: 'assets/images/project-06.jpg',
  ),
];
