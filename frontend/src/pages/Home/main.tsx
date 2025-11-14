import { Link } from 'react-router-dom';

export const HomePage = () => {
  return (
    <div className="container mx-auto px-4 py-12">
      <div className="text-center">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">Bem-vindo ao LoveCakes</h1>
        <p className="text-xl text-gray-600 mb-8">Bolos artesanais feitos com amor e carinho</p>
        <Link
          to="/produtos"
          className="inline-block bg-pink-600 text-white px-8 py-3 rounded-lg font-semibold hover:bg-pink-700 transition-colors"
        >
          Ver Produtos
        </Link>
      </div>
    </div>
  );
};

export default HomePage;
