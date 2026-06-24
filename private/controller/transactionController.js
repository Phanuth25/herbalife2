import Transaction from '../model/transactionModel.js';

export function saveTransaction(req, res) {
    const { userid, md5, amount, bill_number, status } = req.body;
    Transaction.create({ userid, md5, amount, bill_number, status }, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            success: true,
            message: "Transaction saved successfully",
            transactionId: results.insertId
        });
    });
}

export function updateTransaction(req, res) {
    const { md5 } = req.params;
    Transaction.updateStatusByMd5(md5, 'paid', (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            success: true,
            message: "Transaction updated successfully"
        });
    });
}

export function getTransactions(req, res) {
    const { userid } = req.params;
    Transaction.getByUserId(userid, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            success: true,
            message: "Transactions fetched",
            data: results
        });
    });
}
