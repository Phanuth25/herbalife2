const Transaction = require('../model/transactionModel');

exports.saveTransaction = (req, res) => {
    const { userid, md5, amount, bill_number, status } = req.body;
    Transaction.create({ userid, md5, amount, bill_number, status }, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            success: true,
            message: "Transaction saved successfully",
            transactionId: results.insertId
        });
    });
};

exports.updateTransaction = (req, res) => {
    const { md5 } = req.params;
    Transaction.updateStatusByMd5(md5, 'paid', (err) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            success: true,
            message: "Transaction updated successfully"
        });
    });
};

exports.getTransactions = (req, res) => {
    const { userid } = req.params;
    Transaction.getByUserId(userid, (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.status(200).json({
            success: true,
            message: "Transactions fetched",
            data: results
        });
    });
};
