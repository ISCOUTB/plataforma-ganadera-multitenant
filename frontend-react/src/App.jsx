import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import ProtectedRoute from './components/ProtectedRoute';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Fincas from './pages/Fincas';
import Animales from './pages/Animales';

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route
          path="/dashboard"
          element={
            <ProtectedRoute>
              <Dashboard />
            </ProtectedRoute>
          }
        />
        <Route
          path="/fincas"
          element={
            <ProtectedRoute>
              <Fincas />
            </ProtectedRoute>
          }
        />
        <Route
          path="/animales"
          element={
            <ProtectedRoute>
              <Animales />
            </ProtectedRoute>
          }
        />
        {/* Ruta raíz → dashboard si autenticado, login si no */}
        <Route path="/" element={<Navigate to="/dashboard" replace />} />
        <Route path="*" element={<Navigate to="/dashboard" replace />} />
      </Routes>
    </BrowserRouter>
  );
}
