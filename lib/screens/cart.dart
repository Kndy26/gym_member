// lib/screens/cart.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/membership.dart';
import '../providers/membership_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final membershipProvider = Provider.of<MembershipProvider>(context);

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    double subtotal = 0;
    int biayaLayanan = 5000;
    int ppn = 0;
    double total = 0;

    if (membershipProvider.selectedMembership != null) {
      subtotal = membershipProvider.selectedMembership!.harga.toDouble();
      ppn = (subtotal * 0.05).toInt();
      total = subtotal + biayaLayanan + ppn;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Ringkasan Pesanan'),
        backgroundColor: const Color(0xFF8AC6D1),
        elevation: 0,
        centerTitle: true,
      ),
      body: membershipProvider.isCartEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Item yang akan dibeli",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildItemCard(membershipProvider.selectedMembership!,
                      currencyFormatter),
                  const SizedBox(height: 24),
                  const Text(
                    "Rincian Pembayaran",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                            'Harga Paket', subtotal, currencyFormatter),
                        const SizedBox(height: 12),
                        _buildSummaryRow('Biaya Layanan',
                            biayaLayanan.toDouble(), currencyFormatter),
                        const SizedBox(height: 12),
                        _buildSummaryRow(
                            'PPN (5%)', ppn.toDouble(), currencyFormatter),
                        const Divider(
                            height: 30, thickness: 1, color: Colors.grey),
                        _buildSummaryRow(
                            'Total Pembayaran', total, currencyFormatter,
                            isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Provider.of<MembershipProvider>(context,
                                    listen: false)
                                .clearCart();
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Batalkan"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            _showPaymentMethodSheet(context,
                                membershipProvider.selectedMembership!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8AC6D1),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                          child: const Text("Pilih Pembayaran",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Keranjang Anda kosong',
            style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cari Membership",
                style: TextStyle(color: Color(0xFF8AC6D1))),
          )
        ],
      ),
    );
  }

  Widget _buildItemCard(Membership item, NumberFormat formatter) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                item.gambar[0],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(item.deskripsi,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  Text(formatter.format(item.harga),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8AC6D1),
                          fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, NumberFormat formatter,
      {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          formatter.format(value),
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? const Color(0xFF8AC6D1) : Colors.black87,
          ),
        ),
      ],
    );
  }

  void _showPaymentMethodSheet(BuildContext context, Membership membership) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return CheckoutSheet(membership: membership, parentContext: context);
      },
    );
  }
}

enum PaymentMethod { cash, qris }

class CheckoutSheet extends StatefulWidget {
  final Membership membership;
  final BuildContext
      parentContext; // Ini adalah context Halaman Cart (bukan Sheet)

  const CheckoutSheet({
    super.key,
    required this.membership,
    required this.parentContext,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  PaymentMethod _selectedMethod = PaymentMethod.cash;

  // === 1. FUNGSI FINALISASI TRANSAKSI (Dijalankan setelah semua UI selesai) ===
  void _finalizeTransaction() {
    // Gunakan 'widget.parentContext' karena Sheet mungkin sudah ditutup
    final provider =
        Provider.of<MembershipProvider>(widget.parentContext, listen: false);
    provider.setActiveMembership(widget.membership);

    // Kirim sinyal sukses kembali ke HomeScreen
    if (widget.parentContext.mounted) {
      Navigator.pop(widget.parentContext, 'checkout_success');
    }
  }

  // === 2. FUNGSI DIALOG QRIS (Menggunakan Parent Context) ===
  void _showQRISDialog(BuildContext targetContext) {
    showDialog(
      context:
          targetContext, // Dialog muncul di atas CartScreen, bukan di atas Sheet
      barrierDismissible: false,
      builder: (BuildContext dialogCtx) {
        // Timer otomatis tutup dialog QR
        Future.delayed(const Duration(seconds: 4), () {
          if (dialogCtx.mounted) {
            Navigator.of(dialogCtx).pop(); // Tutup Dialog QR
          }
        });

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Scan QRIS",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=MuGenGym-${DateTime.now().millisecondsSinceEpoch}',
                    width: 150,
                    height: 150,
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                          width: 150,
                          height: 150,
                          child: Center(child: CircularProgressIndicator()));
                    },
                    errorBuilder: (ctx, err, stack) => const SizedBox(
                        width: 150,
                        height: 150,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.qr_code_2,
                                  size: 50, color: Colors.grey),
                              Text("Gagal memuat QR",
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.grey))
                            ])),
                  ),
                ),
                const SizedBox(height: 20),
                const LinearProgressIndicator(color: Color(0xFF8AC6D1)),
                const SizedBox(height: 10),
                const Text("Menunggu pembayaran...",
                    style: TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // === SETELAH DIALOG QR TERTUTUP ===
      _finalizeTransaction();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih Metode Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildPaymentOption(
              title: 'Tunai di Kasir',
              icon: Icons.storefront,
              value: PaymentMethod.cash),
          const SizedBox(height: 12),
          _buildPaymentOption(
              title: 'QRIS (GoPay/OVO/Dana)',
              icon: Icons.qr_code_2,
              value: PaymentMethod.qris),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Simpan context parent ke variabel lokal agar aman
                final parentContext = widget.parentContext;

                if (_selectedMethod == PaymentMethod.qris) {
                  Navigator.pop(context); // 1. Tutup BottomSheet dulu
                  _showQRISDialog(
                      parentContext); // 2. Buka Dialog QR di Parent Context
                } else {
                  Navigator.pop(context); // 1. Tutup BottomSheet
                  _finalizeTransaction(); // 2. Selesai
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8AC6D1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Konfirmasi & Bayar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      {required String title,
      required IconData icon,
      required PaymentMethod value}) {
    bool isSelected = _selectedMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF8AC6D1) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? const Color(0xFF8AC6D1) : Colors.grey),
            const SizedBox(width: 16),
            Text(title,
                style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.black : Colors.grey[700])),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF8AC6D1)),
          ],
        ),
      ),
    );
  }
}
