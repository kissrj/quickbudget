import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../utils/constants.dart';

class DataExportService {
  final TransactionService _transactionService;

  DataExportService(this._transactionService);

  Future<void> exportDataToPDF({
    List<Transaction>? transactions,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      // Get transactions to export
      List<Transaction> transactionsToExport;
      if (transactions != null) {
        transactionsToExport = transactions;
      } else {
        transactionsToExport = _transactionService.getAllTransactions();

        // Apply date filter if provided
        if (startDate != null || endDate != null) {
          transactionsToExport = transactionsToExport.where((transaction) {
            if (startDate != null && transaction.date.isBefore(startDate)) {
              return false;
            }
            if (endDate != null && transaction.date.isAfter(endDate)) {
              return false;
            }
            return true;
          }).toList();
        }
      }

      if (transactionsToExport.isEmpty) {
        throw Exception('Nenhuma transação encontrada para exportar');
      }

      // Create PDF document
      final pdf = pw.Document();

      // Add content to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Relatório Financeiro - QuickBudget',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              // Period
              pw.Paragraph(
                text:
                    'Período: ${startDate != null ? DateFormat('dd/MM/yyyy').format(startDate) : 'Todo período'} - ${endDate != null ? DateFormat('dd/MM/yyyy').format(endDate) : 'Atual'}',
                style: const pw.TextStyle(fontSize: 12),
              ),

              // Summary
              pw.SizedBox(height: 20),
              _buildSummarySection(transactionsToExport, currency ?? 'BRL'),

              // Transactions table
              pw.SizedBox(height: 30),
              _buildTransactionsTable(transactionsToExport, currency ?? 'BRL'),

              // Footer
              pw.SizedBox(height: 30),
              pw.Text(
                'Relatório gerado em ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ];
          },
        ),
      );

      // Save PDF to temporary file
      final output = await getTemporaryDirectory();
      final fileName =
          'relatorio_quickbudget_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
      final file = File('${output.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Relatório financeiro do QuickBudget',
        subject: 'Relatório Financeiro',
      );
    } catch (e) {
      throw Exception('Erro ao exportar dados: $e');
    }
  }

  pw.Widget _buildSummarySection(
    List<Transaction> transactions,
    String currency,
  ) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpense;

    final currencySymbol = _getCurrencySymbol(currency);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.blue),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumo Financeiro',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Receitas:'),
              pw.Text('${currencySymbol}${_formatCurrency(totalIncome)}'),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Despesas:'),
              pw.Text('${currencySymbol}${_formatCurrency(totalExpense)}'),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Saldo:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${currencySymbol}${_formatCurrency(balance)}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: balance >= 0 ? PdfColors.green : PdfColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTransactionsTable(
    List<Transaction> transactions,
    String currency,
  ) {
    final currencySymbol = _getCurrencySymbol(currency);

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('Data', isHeader: true),
            _buildTableCell('Descrição', isHeader: true),
            _buildTableCell('Categoria', isHeader: true),
            _buildTableCell('Tipo', isHeader: true),
            _buildTableCell('Valor', isHeader: true),
          ],
        ),
        // Data rows
        ...transactions.map((transaction) {
          return pw.TableRow(
            children: [
              _buildTableCell(
                DateFormat('dd/MM/yyyy').format(transaction.date),
              ),
              _buildTableCell(transaction.description),
              _buildTableCell(transaction.categoryDisplayName),
              _buildTableCell(
                transaction.type == TransactionType.income
                    ? 'Receita'
                    : 'Despesa',
                color: transaction.type == TransactionType.income
                    ? PdfColors.green
                    : PdfColors.red,
              ),
              _buildTableCell(
                '${currencySymbol}${_formatCurrency(transaction.amount)}',
                color: transaction.type == TransactionType.income
                    ? PdfColors.green
                    : PdfColors.red,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? PdfColors.black,
        ),
      ),
    );
  }

  String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'BRL':
        return 'R\$';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      default:
        return currency;
    }
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: '');
    return formatter.format(value);
  }

  Future<void> exportDataToJSON() async {
    try {
      final transactions = await _transactionService.getAllTransactions();

      if (transactions.isEmpty) {
        throw Exception('Nenhuma transação encontrada para exportar');
      }

      // Convert transactions to JSON
      final jsonData = transactions
          .map(
            (t) => {
              'id': t.id,
              'description': t.description,
              'amount': t.amount,
              'category': t.categoryDisplayName,
              'type': t.type.toString(),
              'date': t.date.toIso8601String(),
            },
          )
          .toList();

      // Create JSON file
      final output = await getTemporaryDirectory();
      final fileName =
          'dados_quickbudget_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.json';
      final file = File('${output.path}/$fileName');

      final jsonString = jsonData.toString();
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Dados do QuickBudget em formato JSON',
        subject: 'Backup de Dados',
      );
    } catch (e) {
      throw Exception('Erro ao exportar dados JSON: $e');
    }
  }
}
