import { Link } from 'react-router-dom';

export const NotFoundPage = () => {
  return (
    <div className="container mx-auto px-4 py-12">
      <div className="text-center">
        <h1 className="text-6xl font-bold text-gray-900 mb-4">404</h1>
        <p className="text-xl text-gray-600 mb-8">Página não encontrada</p>
        <Link
          to="/"
          className="inline-block bg-pink-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-pink-700 transition-colors"
        >
          Voltar para Início
        </Link>
      </div>
    </div>
  );
};

export default NotFoundPage;
