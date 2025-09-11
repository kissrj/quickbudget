import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../services/subscription_service.dart';
import '../utils/constants.dart';

class PdfService {
  final SubscriptionService _subscriptionService;

  PdfService(this._subscriptionService);

  // Generate PDF report for transactions
  Future<void> generateTransactionReport(
    BuildContext context,
    List<Transaction> transactions,
    String title,
  ) async {
    if (!_subscriptionService.isPremium) {
      throw Exception('PDF export is only available for Premium users');
    }

    final pdf = pw.Document();

    // Add content to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader(title),
          pw.SizedBox(height: 20),
          _buildSummary(transactions),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    // Save and share PDF
    await _saveAndSharePdf(pdf, title);
  }

  pw.Widget _buildHeader(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'QuickBudget',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(
          'Gerado em ${DateTime.now().toString().split('.')[0]}',
          style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
        ),
        pw.Divider(),
      ],
    );
  }

  pw.Widget _buildSummary(List<Transaction> transactions) {
    final totalIncome = transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalIncome - totalExpenses;

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Resumo',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total de Receitas:'),
              pw.Text(
                'R\$ ${totalIncome.toStringAsFixed(2)}',
                style: const pw.TextStyle(color: PdfColors.green),
              ),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total de Despesas:'),
              pw.Text(
                'R\$ ${totalExpenses.toStringAsFixed(2)}',
                style: const pw.TextStyle(color: PdfColors.red),
              ),
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
                'R\$ ${balance.toStringAsFixed(2)}',
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

  pw.Widget _buildTransactionTable(List<Transaction> transactions) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableCell('Data', isHeader: true),
            _buildTableCell('Descrição', isHeader: true),
            _buildTableCell('Categoria', isHeader: true),
            _buildTableCell('Tipo', isHeader: true),
            _buildTableCell('Valor', isHeader: true),
          ],
        ),
        // Data rows
        ...transactions.map(
          (transaction) => pw.TableRow(
            children: [
              _buildTableCell(
                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
              ),
              _buildTableCell(transaction.description),
              _buildTableCell(transaction.categoryDisplayName),
              _buildTableCell(transaction.typeDisplayName),
              _buildTableCell(
                'R\$ ${transaction.amount.toStringAsFixed(2)}',
                color: transaction.type == TransactionType.income
                    ? PdfColors.green
                    : PdfColors.red,
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 10 : 9,
          fontWeight: isHeader ? pw.FontWeight.bold : null,
          color: color,
        ),
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.Text(
          'Relatório gerado pelo QuickBudget',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
        ),
        pw.Text(
          'Versão Premium',
          style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
        ),
      ],
    );
  }

  Future<void> _saveAndSharePdf(pw.Document pdf, String title) async {
    try {
      // Get temporary directory
      final output = await getTemporaryDirectory();
      final fileName =
          '${title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${output.path}/$fileName');

      // Save PDF
      await file.writeAsBytes(await pdf.save());

      // Share PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Relatório de Transações - $title',
        subject: 'QuickBudget Report',
      );
    } catch (e) {
      throw Exception('Erro ao salvar PDF: $e');
    }
  }

  // Print PDF directly
  Future<void> printReport(
    BuildContext context,
    List<Transaction> transactions,
    String title,
  ) async {
    if (!_subscriptionService.isPremium) {
      throw Exception('Impressão de PDF é apenas para usuários Premium');
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          _buildHeader(title),
          pw.SizedBox(height: 20),
          _buildSummary(transactions),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
