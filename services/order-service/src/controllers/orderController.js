const pool = require("../config/db");

const createOrder = async (req, res) => {
    try {
        const { items } = req.body;

        if (!items || items.length === 0) {
            return res.status(400).json({
                message: "Order items are required"
            });
        }

        let totalAmount = 0;

        for (const item of items) {
            if (!item.product_id || !item.quantity || item.quantity <= 0) {
                return res.status(400).json({
                    message: "Invalid order item"
                });
            }

            const response = await fetch(
                `${process.env.PRODUCT_SERVICE_URL}/api/products/${item.product_id}`
            );

            if (!response.ok) {
                return res.status(400).json({
                    message: `Product ${item.product_id} not found`
                });
            }

            const product = await response.json();

            if (product.stock < item.quantity) {
                return res.status(400).json({
                    message: `Insufficient stock for product ${item.product_id}`
                });
            }

            totalAmount += Number(product.price) * item.quantity;
        }

        const client = await pool.connect();

        try {
            await client.query("BEGIN");

            const orderResult = await client.query(
                `INSERT INTO orders (user_id, total_amount, status)
                 VALUES ($1, $2, $3)
                 RETURNING *`,
                [req.user.id, totalAmount, "PENDING"]
            );

            const order = orderResult.rows[0];

            for (const item of items) {
                const response = await fetch(
                    `${process.env.PRODUCT_SERVICE_URL}/api/products/${item.product_id}`
                );

                const product = await response.json();

                await client.query(
                    `INSERT INTO order_items
                     (order_id, product_id, quantity, price)
                     VALUES ($1, $2, $3, $4)`,
                    [
                        order.id,
                        item.product_id,
                        item.quantity,
                        product.price
                    ]
                );
            }

            await client.query("COMMIT");

            res.status(201).json({
                message: "Order created successfully",
                order
            });

        } catch (error) {
            await client.query("ROLLBACK");
            throw error;
        } finally {
            client.release();
        }

    } catch (error) {
        console.error("Create order error:", error);

        res.status(500).json({
            message: "Internal server error"
        });
    }
};

module.exports = {
    createOrder
};