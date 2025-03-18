import 'package:flutter/material.dart';

class DashboardMenuItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  const DashboardMenuItem({
    super.key,
    required this.icon,
    required this.description,
    required this.label,
  });

  @override
  State<DashboardMenuItem> createState() => _DashboardMenuItemState();
}

class _DashboardMenuItemState extends State<DashboardMenuItem> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        isHovered = true;
      }),
      onExit: (_) => setState(() {
        isHovered = false;
      }),
      child: Container(
        color: isHovered ? Theme.of(context).colorScheme.primary : Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Icon(widget.icon, size: 80, color: isHovered ? Colors.white : Theme.of(context).colorScheme.secondary,),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.label, 
                  style: TextStyle(
                    color: isHovered ? Colors.white : Colors.black,
                    overflow: TextOverflow.ellipsis
                    ),
                  ),
                  Text(widget.description, 
                  style: TextStyle(
                    color: isHovered ? Colors.white : Colors.black,
                    overflow: TextOverflow.ellipsis,
                    fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
          ]
        )
      ),
    );
  }
}