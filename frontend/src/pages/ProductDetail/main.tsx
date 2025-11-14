import { useParams } from 'react-router-dom';

export const ProductDetailPage = () => {
  const { id } = useParams<{ id: string }>();

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold text-gray-900 mb-8">Detalhes do Produto</h1>
      <div className="text-center text-gray-600">
        <p>Detalhes do produto {id} serão implementados aqui</p>
      </div>
    </div>
  );
};

export default ProductDetailPage;
