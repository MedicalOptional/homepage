const express = require('express');
const cors = require('cors');
const { MongoClient } = require('mongodb');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI;
const DB_NAME = process.env.DB_NAME || 'tienda';

let db;
const client = new MongoClient(MONGODB_URI);

app.use(cors());
app.use(express.json());

async function connectDB() {
  try {
    await client.connect();
    db = client.db(DB_NAME);
    console.log('✓ Conectado a MongoDB');
  } catch (err) {
    console.error('✗ Error conectando a MongoDB:', err);
    process.exit(1);
  }
}

app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const users = db.collection('users');
    const user = await users.findOne({ email, password });

    if (user) {
      return res.json({
        success: true,
        user: {
          id: user._id.toString(),
          name: user.name,
          email: user.email
        }
      });
    }

    return res.status(401).json({
      success: false,
      message: 'Credenciales incorrectas'
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.post('/auth/register', async (req, res) => {
  try {
    const { name, email, password } = req.body;
    const users = db.collection('users');

    const existing = await users.findOne({ email });
    if (existing) {
      return res.status(409).json({
        success: false,
        message: 'El correo ya está registrado'
      });
    }

    const result = await users.insertOne({
      name,
      email,
      password,
      createdAt: new Date()
    });

    res.json({
      success: true,
      user: {
        id: result.insertedId.toString(),
        name,
        email
      }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

app.get('/products', async (req, res) => {
  try {
    const category = req.query.category;
    const products = db.collection('products');

    const query = (category && category !== 'all') ? { category } : {};
    const data = await products.find(query).toArray();

    res.json(data.map(p => ({
      ...p,
      _id: p._id.toString()
    })));
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error en servidor' });
  }
});

connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Server corriendo en puerto ${PORT}`);
  });
});

process.on('SIGINT', async () => {
  await client.close();
  process.exit(0);
});
