import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    this.onTap,
    this.action,
  });

  final String title;
  final String date;
  final String amount;
  final bool isIncome;
  final VoidCallback? onTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final accentColor =
        isIncome ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final cardColor = isDark
        ? Color.alphaBlend(
            colorScheme.surface.withOpacity(0.6),
            colorScheme.surfaceVariant,
          )
        : colorScheme.surface;
    final textColor =
        isDark ? colorScheme.onSurface.withOpacity(0.95) : colorScheme.onSurface;
    final secondaryTextColor = isDark
        ? colorScheme.onSurface.withOpacity(0.7)
        : colorScheme.onSurface.withOpacity(0.6);
    final pillColor = accentColor.withOpacity(isDark ? 0.24 : 0.12);
    final borderColor = isDark
        ? colorScheme.outline.withOpacity(0.35)
        : colorScheme.outline.withOpacity(0.08);
    final icon = isIncome ? FontAwesomeIcons.arrowDown : FontAwesomeIcons.arrowUp;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.35)
                    : Colors.black.withOpacity(0.06),
                blurRadius: isDark ? 18 : 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FaIcon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.calendarDays,
                          size: 12,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: pillColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  amount,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 8),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
