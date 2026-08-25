import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/models/chord_model.dart';
import '../providers/chord_catalog_provider.dart';
import '../widgets/cuatro_fretboard_widget.dart';
import '../widgets/glass_card.dart';

class TabChordsScreen extends StatelessWidget {
  final ChordCatalogProvider provider;

  const TabChordsScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final selectedChord = provider.selectedChord;
    final scrollController = ScrollController();

    return ScrollConfiguration(
      behavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
        },
      ),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        interactive: true,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            const Text(
              'Catálogo de Acordes',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${provider.chords.length} de ${provider.totalChords} acordes',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
              child: TextField(
                onChanged: provider.setSearchQuery,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Buscar por nombre o notación',
                  hintStyle: const TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.primaryAmber,
                  ),
                  suffixIcon: provider.searchQuery.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar búsqueda',
                          onPressed: provider.clearSearch,
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text(
                  'Ordenar por',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<ChordSortOption>(
                  value: provider.sortOption,
                  dropdownColor: AppColors.backgroundCard,
                  underline: const SizedBox.shrink(),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primaryAmber,
                  ),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: ChordSortOption.notation,
                      child: Text('Notación'),
                    ),
                    DropdownMenuItem(
                      value: ChordSortOption.name,
                      child: Text('Nombre'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) provider.setSortOption(value);
                  },
                ),
                IconButton(
                  tooltip: provider.sortAscending
                      ? 'Orden descendente'
                      : 'Orden ascendente',
                  onPressed: provider.toggleSortDirection,
                  icon: Icon(
                    provider.sortAscending
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: AppColors.primaryAmber,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (provider.chords.isEmpty)
              const GlassCard(
                child: Text(
                  'No se encontraron acordes con esa búsqueda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              GlassCard(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.builder(
                  itemCount: provider.chords.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final chord = provider.chords[index];
                    return _ChordListTile(
                      chord: chord,
                      isSelected: chord == selectedChord,
                      onTap: () => provider.selectChord(chord),
                    );
                  },
                ),
              ),
            if (selectedChord != null) ...[
              const SizedBox(height: 16),
              GlassCard(
                margin: EdgeInsets.zero,
                borderColor: AppColors.primaryAmber,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedChord.displayTitle,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pisada: ${selectedChord.frets.join(' - ')}',
                                style: const TextStyle(
                                  color: AppColors.accentCyan,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: AppStrings.playChord,
                          onPressed: provider.playSelectedChord,
                          icon: const Icon(
                            Icons.volume_up,
                            color: AppColors.primaryAmber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: CuatroFretboardWidget(frets: selectedChord.frets),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChordListTile extends StatelessWidget {
  final ChordModel chord;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChordListTile({
    required this.chord,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryAmber.withValues(alpha: 0.14)
                : null,
            border: Border(
              left: BorderSide(
                color: isSelected ? AppColors.primaryAmber : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  chord.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.primaryAmber
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                chord.frets.join('-'),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
