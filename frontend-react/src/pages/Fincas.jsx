import { useState, useEffect, useCallback } from 'react';
import Navbar from '../components/Navbar';
import { getFincas, createFinca, deleteFinca } from '../fincas/fincas.service';

const EMPTY_FORM = { pk_id_finca: '', nombre_finca: '', ubicacion: '', area_total: '' };

export default function Fincas() {
  const [fincas, setFincas] = useState([]);
  const [form, setForm] = useState(EMPTY_FORM);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      setFincas(await getFincas());
    } catch (err) {
      setError('No se pudieron cargar las fincas');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { load(); }, [load]);

  async function handleSubmit(e) {
    e.preventDefault();
    setSubmitting(true);
    setError('');
    try {
      const payload = {
        pk_id_finca: form.pk_id_finca.trim(),
        nombre_finca: form.nombre_finca.trim(),
        ...(form.ubicacion && { ubicacion: form.ubicacion.trim() }),
        ...(form.area_total && { area_total: parseFloat(form.area_total) }),
      };
      await createFinca(payload);
      setForm(EMPTY_FORM);
      setShowForm(false);
      await load();
    } catch (err) {
      const msg = err.response?.data?.message;
      setError(Array.isArray(msg) ? msg.join(', ') : (msg || 'Error al crear la finca'));
    } finally {
      setSubmitting(false);
    }
  }

  async function handleDelete(id) {
    if (!confirm(`¿Eliminar la finca "${id}"?`)) return;
    try {
      await deleteFinca(id);
      await load();
    } catch {
      setError('No se pudo eliminar la finca');
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <div className="max-w-4xl mx-auto px-4 py-8">
        <div className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold text-gray-800">Fincas</h1>
          <button
            onClick={() => { setShowForm(!showForm); setError(''); }}
            className="bg-green-700 hover:bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors"
          >
            {showForm ? '✕ Cancelar' : '+ Nueva Finca'}
          </button>
        </div>

        {error && (
          <div className="bg-red-50 border border-red-200 text-red-700 text-sm rounded-lg px-4 py-3 mb-4">
            {error}
          </div>
        )}

        {showForm && (
          <form onSubmit={handleSubmit} className="bg-white border border-gray-200 rounded-xl p-6 mb-6 shadow-sm">
            <h2 className="text-base font-semibold text-gray-700 mb-4">Nueva Finca</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  ID Finca *
                </label>
                <input
                  required
                  maxLength={15}
                  value={form.pk_id_finca}
                  onChange={(e) => setForm({ ...form, pk_id_finca: e.target.value })}
                  placeholder="FINCA001"
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Nombre *
                </label>
                <input
                  required
                  maxLength={100}
                  value={form.nombre_finca}
                  onChange={(e) => setForm({ ...form, nombre_finca: e.target.value })}
                  placeholder="Hacienda El Paraíso"
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Ubicación
                </label>
                <input
                  value={form.ubicacion}
                  onChange={(e) => setForm({ ...form, ubicacion: e.target.value })}
                  placeholder="Córdoba, Colombia"
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
              <div>
                <label className="block text-xs font-medium text-gray-600 mb-1">
                  Área total (ha)
                </label>
                <input
                  type="number"
                  min="0"
                  step="0.1"
                  value={form.area_total}
                  onChange={(e) => setForm({ ...form, area_total: e.target.value })}
                  placeholder="250.5"
                  className="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-green-500"
                />
              </div>
            </div>
            <div className="mt-4 flex justify-end">
              <button
                type="submit"
                disabled={submitting}
                className="bg-green-700 hover:bg-green-600 disabled:bg-green-300 text-white px-5 py-2 rounded-lg text-sm font-medium transition-colors"
              >
                {submitting ? 'Guardando...' : 'Guardar Finca'}
              </button>
            </div>
          </form>
        )}

        {loading ? (
          <div className="text-center py-12 text-gray-400">Cargando fincas...</div>
        ) : fincas.length === 0 ? (
          <div className="text-center py-12 text-gray-400">
            <div className="text-4xl mb-2">🏡</div>
            <p>No hay fincas registradas. Crea la primera.</p>
          </div>
        ) : (
          <div className="bg-white border border-gray-200 rounded-xl shadow-sm overflow-hidden">
            <table className="w-full text-sm">
              <thead className="bg-gray-50 text-gray-600 text-xs uppercase">
                <tr>
                  <th className="px-4 py-3 text-left">ID</th>
                  <th className="px-4 py-3 text-left">Nombre</th>
                  <th className="px-4 py-3 text-left">Ubicación</th>
                  <th className="px-4 py-3 text-right">Área (ha)</th>
                  <th className="px-4 py-3 text-center">Acciones</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {fincas.map((f) => (
                  <tr key={f.pk_id_finca} className="hover:bg-gray-50">
                    <td className="px-4 py-3 font-mono text-xs text-gray-600">{f.pk_id_finca}</td>
                    <td className="px-4 py-3 font-medium text-gray-800">{f.nombre_finca}</td>
                    <td className="px-4 py-3 text-gray-500">{f.ubicacion || '—'}</td>
                    <td className="px-4 py-3 text-right text-gray-500">{f.area_total ?? '—'}</td>
                    <td className="px-4 py-3 text-center">
                      <button
                        onClick={() => handleDelete(f.pk_id_finca)}
                        className="text-red-500 hover:text-red-700 text-xs px-2 py-1 rounded hover:bg-red-50 transition-colors"
                      >
                        Eliminar
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </div>
  );
}
