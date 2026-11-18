const express = require('express');
const app = express();
app.use(express.json());                 // parse JSON request bodies

let notes = [ { id: 1, title: 'First note', body: 'Hello from the server' } ];
let nextId = 2;

// GET /api/notes : return every note
app.get('/api/notes', (req, res) => {
  res.json(notes);
});

// GET /api/notes/:id : return one note, or 404 if it does not exist
app.get('/api/notes/:id', (req, res) => {
  const note = notes.find(n => n.id === Number(req.params.id));
  if (!note) return res.status(404).json({ error: 'Note not found' });
  res.json(note);
});

// POST /api/notes : create a note from the JSON body
app.post('/api/notes', (req, res) => {
  const { title, body } = req.body;
  if (!title) return res.status(400).json({ error: 'title is required' });
  const note = { id: nextId++, title, body: body || '' };
  notes.push(note);
  res.status(201).json(note);
});

// DELETE /api/notes/:id : remove a note
app.delete('/api/notes/:id', (req, res) => {
  const before = notes.length;
  notes = notes.filter(n => n.id !== Number(req.params.id));
  if (notes.length === before) return res.status(404).json({ error: 'Note not found' });
  res.status(204).end();
});

app.listen(3000, () => console.log('Notes API on http://localhost:3000'));
