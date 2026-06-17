const express = require('express');
const router = express.Router();
const db = require('../model/db');
const verifyToken = require('../middleware/auth');


router.patch('/removeinfos', verifyToken, (req,res)=>{
  const {id, point} = req.body;
   const sql = 'update infos set point = point - ? where id = ?';
   db.query(sql,[point,id],(err,result)=>{
           if (err) {
               return res.status(500).json({
                   success: false,
                   error: err.message
               });
           }

           // Check if the record actually existed/was updated
           if (result.affectedRows === 0) {
               return res.status(404).json({
                   success: false,
                   message: "Record not found"
               });
           }

           res.status(200).json({
               success: true,
               message: "Points deducted successfully",
               point: point
           });
   });
});

module.exports = router;