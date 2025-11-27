import { useState } from 'react'
import DiarizationResults from './DiarizationResults'

const API_BASE_URL = 'http://localhost:5002'

export default function FileUpload() {
    const [file, setFile] = useState(null)
    const [isLoading, setIsLoading] = useState(false)
    const [results, setResults] = useState(null)
    const [error, setError] = useState(null)

    const handleFileChange = (e) => {
        const selectedFile = e.target.files[0]
        if (selectedFile) {
            setFile(selectedFile)
            setResults(null)
            setError(null)
        }
    }

    const handleUpload = async () => {
        if (!file) return

        console.log('🚀 Début upload fichier:', file.name)
        setIsLoading(true)
        setError(null)

        const formData = new FormData()
        formData.append('audio', file)
        console.log('📦 FormData créé')

        try {
            console.log('🏥 Test health check...')
            const healthResponse = await fetch(`${API_BASE_URL}/health`)
            console.log('🏥 Health check:', healthResponse.status)
            
            if (!healthResponse.ok) {
                throw new Error('Le serveur n\'est pas accessible. Assurez-vous que le backend FastAPI est lancé sur le port 5002')
            }
            
            console.log('📡 Envoi vers /diarize...')
            const response = await fetch(`${API_BASE_URL}/diarize`, {
                method: 'POST',
                body: formData,
                signal: AbortSignal.timeout(300000)
            })

            console.log('📥 Réponse reçue:', response.status, response.statusText)
            
            if (!response.ok) {
                const errorData = await response.json()
                throw new Error(errorData.detail || `HTTP ${response.status}: ${response.statusText}`)
            }

            const data = await response.json()
            console.log('📊 Données reçues:', data)

            if (!data.success) {
                console.error('❌ Erreur serveur:', data.error)
                setError(data.error)
            } else {
                console.log('✅ Résultats reçus')
                setResults(data)
            }
        } catch (err) {
            console.error('❌ Erreur Upload:', err)
            setError(`Erreur: ${err.message}`)
        } finally {
            setIsLoading(false)
            console.log('🏁 Upload terminé')
        }
    }

    return (
        <div className="bg-white rounded-lg shadow-lg p-8">
            <div className="mb-6">
                <label className="block text-sm font-medium text-gray-700 mb-2">
                    Sélectionner un fichier audio
                </label>
                <div className="flex items-center gap-4">
                    <label className="flex-1 cursor-pointer">
                        <div className="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center hover:border-primary-500 transition-colors">
                            <svg className="mx-auto h-12 w-12 text-gray-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                                <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                            <p className="mt-2 text-sm text-gray-600">
                                {file ? file.name : 'Cliquez pour sélectionner un fichier'}
                            </p>
                            <p className="mt-1 text-xs text-gray-500">MP3, WAV, M4A</p>
                        </div>
                        <input
                            type="file"
                            accept="audio/*"
                            onChange={handleFileChange}
                            className="hidden"
                        />
                    </label>
                </div>
            </div>

            <button
                onClick={handleUpload}
                disabled={!file || isLoading}
                className={`w-full py-3 px-6 rounded-lg font-medium transition-all duration-200 ${!file || isLoading
                        ? 'bg-gray-300 text-gray-500 cursor-not-allowed'
                        : 'bg-primary-500 text-white hover:bg-primary-600 shadow-md hover:shadow-lg'
                    }`}
            >
                {isLoading ? (
                    <span className="flex items-center justify-center gap-2">
                        <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                            <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                            <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        Analyse en cours...
                    </span>
                ) : (
                    'Analyser le fichier'
                )}
            </button>

            {error && (
                <div className="mt-4 p-4 bg-red-50 border border-red-200 rounded-lg">
                    <p className="text-red-800 text-sm">{error}</p>
                </div>
            )}

            {results && <DiarizationResults results={results} />}
        </div>
    )
}
