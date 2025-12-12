import express from "express";
import admin from "firebase-admin";
import cors from "cors";
import fs from "fs";

const app = express();
app.use(cors());
app.use(express.json());

// Inicializar Firebase Admin
const serviceAccount = JSON.parse(
  fs.readFileSync("./firebase-admin.json", "utf8")
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// ===============================================
// AUTH LOGIN
// ===============================================
app.post("/auth/login", async (req, res) => {
  const { email, password } = req.body;

  // puedes cambiar la lógica, esto es ejemplo
  if (email === "admin@aprende.cl" && password === "123456") {
    return res.json({ ok: true, token: "TOKEN_FAKE_DEMO" });
  }

  return res.status(401).json({ ok: false, message: "Credenciales inválidas" });
});

// ===============================================
// GET STUDENT
// ===============================================
app.get("/students/:id", async (req, res) => {
  const id = req.params.id;
  const doc = await db.collection("students").doc(id).get();

  if (!doc.exists) {
    return res.status(404).json({ ok: false, message: "Estudiante no encontrado" });
  }

  res.json({ ok: true, data: doc.data() });
});

// ===============================================
// CREATE STUDENT
// ===============================================
app.post("/students/create", async (req, res) => {
  const { name, age } = req.body;

  const ref = await db.collection("students").add({
    name,
    age,
    progress: {}
  });

  res.json({ ok: true, id: ref.id });
});

// ===============================================
// UPDATE PROGRESS
// ===============================================
app.put("/students/:id/progress", async (req, res) => {
  const id = req.params.id;
  const { module, score } = req.body;

  await db.collection("students").doc(id).update({
    [`progress.${module}`]: score
  });

  res.json({ ok: true });
});

// ======================================================
// ACTIVITIES: SYLLABLES WORD LIST (conexión a Firestore)
// ======================================================
app.get("/activities/syllables", async (req, res) => {
  const snapshot = await db.collection("syllables").get();

  const list = snapshot.docs.map(d => ({
    id: d.id,
    ...d.data()
  }));

  res.json({ ok: true, words: list });
});

// Puerto local
app.listen(3000, () => {
  console.log("API corriendo en http://localhost:3000");
});
