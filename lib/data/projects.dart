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
  ProjectCategory(id: 'dining', label: 'Dining'),
  ProjectCategory(id: 'kitchens', label: 'Kitchens'),
  ProjectCategory(id: 'bedrooms', label: 'Bedrooms'),
  ProjectCategory(id: 'tv-units', label: 'TV Units'),
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

// `location` and `year` are deliberately left unset: they publish a claim about
// where and when a job was built, and nobody has supplied those details yet.
// Fill them in per project and the tile and lightbox pick them up on their own.
const List<Project> kProjects = <Project>[
  // ---- Living ----
  Project(
    name: 'Ivory Lounge',
    categoryId: 'living',
    image: 'assets/images/living-01.jpg',
  ),
  Project(
    name: 'The Partition Screen',
    categoryId: 'living',
    image: 'assets/images/living-02.jpg',
  ),

  // ---- Dining ----
  Project(
    name: 'Terracotta Six',
    categoryId: 'dining',
    image: 'assets/images/dining-01.jpg',
  ),
  Project(
    name: 'Emerald & Brass',
    categoryId: 'dining',
    image: 'assets/images/dining-02.jpg',
  ),
  Project(
    name: 'Walnut Slat Dining',
    categoryId: 'dining',
    image: 'assets/images/dining-03.jpg',
  ),

  // ---- Kitchens ----
  Project(
    name: 'The Marble Island',
    categoryId: 'kitchens',
    image: 'assets/images/kitchen-01.jpg',
  ),
  Project(
    name: 'Reeded Glass Kitchen',
    categoryId: 'kitchens',
    image: 'assets/images/kitchen-02.jpg',
  ),
  Project(
    name: 'Sage Galley',
    categoryId: 'kitchens',
    image: 'assets/images/kitchen-03.jpg',
  ),
  Project(
    name: 'Champagne Gloss',
    categoryId: 'kitchens',
    image: 'assets/images/kitchen-04.jpg',
  ),

  // ---- Bedrooms ----
  Project(
    name: 'Fluted Calm',
    categoryId: 'bedrooms',
    image: 'assets/images/bedroom-01.jpg',
  ),
  Project(
    name: 'Forest Mural',
    categoryId: 'bedrooms',
    image: 'assets/images/bedroom-02.jpg',
  ),
  Project(
    name: 'Marble & Rust',
    categoryId: 'bedrooms',
    image: 'assets/images/bedroom-03.jpg',
  ),

  // ---- TV units ----
  Project(
    name: 'Fluted Media Wall',
    categoryId: 'tv-units',
    image: 'assets/images/tv-unit-01.jpg',
  ),
  Project(
    name: 'Stone & Slat',
    categoryId: 'tv-units',
    // The source frame is a 9:16 screen capture with grey letterbox bands top
    // and bottom; this crops back to the photograph itself.
    aspectRatio: 0.83,
    image: 'assets/images/tv-unit-02.jpg',
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
