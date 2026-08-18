class ServiceItem {
  const ServiceItem({
    required this.index,
    required this.title,
    required this.description,
  });

  /// Displayed as an oversized numeral — "01", "02" …
  final String index;
  final String title;
  final String description;
}

const List<ServiceItem> kServices = <ServiceItem>[
  ServiceItem(
    index: '01',
    title: 'Interior Design',
    description:
        'Thoughtful interior concepts developed around functionality, '
        'aesthetics, and the character of each space.',
  ),
  ServiceItem(
    index: '02',
    title: 'Space Planning &\nDesign Development',
    description:
        'Carefully planned layouts and design development that balance '
        'practical requirements with visual refinement.',
  ),
  ServiceItem(
    index: '03',
    title: 'Custom Furniture',
    description:
        'Precisely crafted furniture designed specifically to complement the '
        'space and the overall interior concept.',
  ),
  ServiceItem(
    index: '04',
    title: 'Complete Interior\nSolutions',
    description:
        'A seamless design experience from concept development through '
        'execution and furniture production.',
  ),
];
