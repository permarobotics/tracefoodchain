import 'package:flutter/material.dart';
import 'package:trace_foodchain_app/helpers/helpers.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CoffeeProcessingStateSelector extends StatefulWidget {
  final String currentState;
  final List<String> currentQualityCriteria;
  final Function(String, List<String>) onSelectionChanged;
  final String country;

  const CoffeeProcessingStateSelector({
    Key? key,
    required this.currentState,
    required this.currentQualityCriteria,
    required this.onSelectionChanged,
    required this.country,
  }) : super(key: key);

  @override
  _CoffeeProcessingStateSelectorState createState() =>
      _CoffeeProcessingStateSelectorState();
}

class _CoffeeProcessingStateSelectorState
    extends State<CoffeeProcessingStateSelector> {
  late String _selectedState;
  late List<Map<String, dynamic>> _processingStates;
  late List<String> _qualityCriteria;
  late List<String> _selectedQualityCriteria;

  @override
  void initState() {
    super.initState();
    _processingStates = getProcessingStates(widget.country);
    _selectedState = _findMatchingState(widget.currentState);
    _qualityCriteria = getQualityReductionCriteria(widget.country);
    _selectedQualityCriteria = List.from(widget.currentQualityCriteria);
  }

  String _findMatchingState(String currentState) {
    // Find the matching state (case-insensitive)
    final matchingState = _processingStates.firstWhere(
      (state) =>
          state['name']['english'].toLowerCase() == currentState.toLowerCase(),
      orElse: () => _processingStates.first,
    );
    return matchingState['name']['english'];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.selectQualityCriteria,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ..._buildQualityCriteriaCheckboxes(),
        SizedBox(height: 16),
        Text(
          l10n.selectProcessingState,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        _buildProcessingStateSelector(),
      ],
    );
  }

  List<Widget> _buildQualityCriteriaCheckboxes() {
    return _qualityCriteria.map((criteria) {
      return CheckboxListTile(
        title: Text(criteria, style: TextStyle(color: Colors.black87)),
        value: _selectedQualityCriteria.contains(criteria),
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _selectedQualityCriteria.add(criteria);
            } else {
              _selectedQualityCriteria.remove(criteria);
            }
          });
        },
        activeColor: Color(0xFF35DB00),
      );
    }).toList();
  }

  Widget _buildProcessingStateSelector() {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double availableWidth = constraints.maxWidth;
        int crossAxisCount = (availableWidth / 120).floor();
        double itemWidth = (availableWidth / crossAxisCount) - 16;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _processingStates.map((state) {
            final isSelected = state['name']['english'] == _selectedState;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedState = state['name']['english'];
                });
                widget.onSelectionChanged(
                    _selectedState, _selectedQualityCriteria);
              },
              child: Container(
                width: itemWidth,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(0xFF35DB00).withAlpha(120)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIconForState(state['name']['english']),
                      size: 32,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    SizedBox(height: 4),
                    Text(
                      state['name']['english'],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2),
                    Text(
                      state['name']['spanish'],
                      style: TextStyle(
                        color: isSelected ? Colors.white70 : Colors.black54,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  IconData _getIconForState(String state) {
    switch (state.toLowerCase()) {
      case 'cherry':
        return Icons.brightness_1;
      case 'wet parchment':
        return Icons.water;
      case 'dry parchment':
        return Icons.grain;
      case 'green':
        return Icons.eco;
      case 'roasted':
        return Icons.local_fire_department;
      case 'ground roasted':
        return Icons.coffee;
      default:
        return Icons.help_outline;
    }
  }
}
