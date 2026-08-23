/// Portfolio data.
///
/// The portfolio is category-driven: every photograph belongs to exactly one
/// [ProjectCategory], and the filter bar in the UI is generated from
/// [kProjectCategories] — nothing in the widget layer hard-codes a category or
/// a project.
///
/// Swapping in real work is a two-step job:
///   1. Drop the photographs into `assets/images/` (the whole folder is already
///      registered in pubspec.yaml, so no manifest edit is needed).
///   2. List them in [kProjects] with the matching `categoryId`.
///
/// Tiles size themselves from each image's own proportions, so a mixed set of
/// portrait and landscape shots lays out cleanly without being squashed or
/// cropped. Set [Project.aspectRatio] only when you want a deliberate crop.
class ProjectCategory {
  const ProjectCategory({required this.id, required this.label});

  final String id;
  final String label;
}

/// Pseudo-category for the "All" tab — never appears in [kProjectCategories].
const String kAllCategoryId = 'all';

/// Order here is the order of the filter bar. Adding a room type to the
/// portfolio means adding one line here and tagging photographs with its `id`.
const List<ProjectCategory> kProjectCategories = <ProjectCategory>[
  ProjectCategory(id: 'living', label: 'Living Rooms'),
  ProjectCategory(id: 'bedrooms', label: 'Bedrooms'),
  ProjectCategory(id: 'kitchens', label: 'Kitchens'),
  ProjectCategory(id: 'dining', label: 'Dining'),
  ProjectCategory(id: 'workspaces', label: 'Workspaces'),
];

String categoryLabelFor(String id) {
  for (final category in kProjectCategories) {
    if (category.id == id) return category.label;
  }
  return id;
}

class Project {
  const Project({
    required this.name,
    required this.categoryId,
    required this.image,
    this.location,
    this.year,
    this.aspectRatio,
  });

  final String name;

  /// Matches a [ProjectCategory.id].
  final String categoryId;
  final String image;
  final String? location;
  final String? year;

  /// Forces a crop instead of letting the tile take the photograph's own
  /// proportions. Left null for almost everything.
  final double? aspectRatio;

  /// "Living Rooms"
  String get category => categoryLabelFor(categoryId);

  /// "Living Rooms  ·  Kochi"
  String get meta => location == null ? category : '$category  ·  $location';
}

// NOTE: placeholder set. These are the six stock frames the site shipped with,
// sorted into the new categories so the section renders today. Replace the
// entries wholesale once the real photographs land in assets/images/.
const List<Project> kProjects = <Project>[
  Project(
    name: 'Modern Residence',
    categoryId: 'living',
    location: 'Kochi',
    year: '2025',
    image: 'assets/images/project-01.jpg',
  ),
  Project(
    name: 'Contemporary Living',
    categoryId: 'living',
    location: 'Kakkanad',
    year: '2025',
    image: 'assets/images/project-02.jpg',
  ),
  Project(
    name: 'Minimal Workspace',
    categoryId: 'workspaces',
    location: 'Kochi',
    year: '2024',
    image: 'assets/images/project-03.jpg',
  ),
  Project(
    name: 'Quiet Hours',
    categoryId: 'bedrooms',
    location: 'Panampilly Nagar',
    year: '2024',
    image: 'assets/images/project-04.jpg',
  ),
  Project(
    name: 'The Open Kitchen',
    categoryId: 'kitchens',
    location: 'Kakkanad',
    year: '2024',
    image: 'assets/images/project-05.jpg',
  ),
  Project(
    name: 'Stone & Light',
    categoryId: 'dining',
    location: 'Edappally',
    year: '2023',
    image: 'assets/images/project-06.jpg',
  ),
];

/// Every project, or just those in [categoryId]. Preserves declaration order.
List<Project> projectsIn(String categoryId) {
  if (categoryId == kAllCategoryId) return kProjects;
  return kProjects.where((p) => p.categoryId == categoryId).toList();
}

/// Categories that actually have photographs behind them — an empty tab is a
/// dead end, so the filter bar skips it.
List<ProjectCategory> get populatedCategories => kProjectCategories
    .where((c) => kProjects.any((p) => p.categoryId == c.id))
    .toList();
