import { useState, useRef, useEffect } from 'react'

export default function LiveTranscription() {
    const [isRecording, setIsRecording] = useState(false)
    const [transcription, setTranscription] = useState('')
    const [metrics, setMetrics] = useState(null)
    const wsRef = useRef(null)
    const audioContextRef = useRef(null)
    const processorRef = useRef(null)
    const streamRef = useRef(null)

    const startRecording = async () => {
        try {
            console.log('🎤 Démarrage enregistrement...')
            // Réinitialiser la transcription pour un nouvel enregistrement
            setTranscription('')

            const stream = await navigator.mediaDevices.getUserMedia({ audio: true })
            streamRef.current = stream
            console.log('✅ Accès microphone OK')

            // WebSocket connection
            console.log('🔌 Connexion WebSocket vers /ws/transcribe...')
            wsRef.current = new WebSocket('/ws/transcribe')

            wsRef.current.onopen = () => {
                console.log('✅ WebSocket connecté')
                initAudioProcessing(stream)
            }

            wsRef.current.onmessage = (event) => {
                console.log('📥 Message WebSocket reçu:', event.data)
                try {
                    const data = JSON.parse(event.data)
                    if (data.type === 'ping') {
                        console.log('🏓 Ping reçu')
                        return
                    }
                    if (data.type === 'transcription') {
                        console.log('📝 Transcription:', data.text)
                        console.log('📊 Métriques:', data.metrics)
                        setTranscription(prev => prev + ' ' + data.text)
                        
                        // Afficher les métriques dans l'interface
                        setMetrics(data.metrics)
                        return
                    }
                } catch {
                    // Si ce n'est pas du JSON, c'est du texte simple (compatibilité)
                    console.log('📝 Transcription simple:', event.data)
                    setTranscription(prev => prev + ' ' + event.data)
                }
            }

            wsRef.current.onclose = () => {
                console.log('❌ WebSocket fermé par le serveur')
                stopRecording()
                alert('Connexion au serveur perdue. Enregistrement arrêté.')
            }

            wsRef.current.onerror = (error) => {
                console.error('❌ Erreur WebSocket:', error)
                alert('Erreur de connexion au serveur.')
                stopRecording()
            }

            setIsRecording(true)
            console.log('🔴 Enregistrement démarré')
        } catch (err) {
            console.error('❌ Erreur accès micro:', err)
            alert('Impossible d\'accéder au microphone.')
        }
    }

    const initAudioProcessing = (stream) => {
        audioContextRef.current = new (window.AudioContext || window.webkitAudioContext)()

        // Envoi de la config au serveur
        if (wsRef.current.readyState === WebSocket.OPEN) {
            wsRef.current.send(JSON.stringify({
                type: 'config',
                sampleRate: audioContextRef.current.sampleRate
            }))
        }

        const inputSource = audioContextRef.current.createMediaStreamSource(stream)
        processorRef.current = audioContextRef.current.createScriptProcessor(4096, 1, 1)

        inputSource.connect(processorRef.current)
        processorRef.current.connect(audioContextRef.current.destination)

        processorRef.current.onaudioprocess = (e) => {
            const inputData = e.inputBuffer.getChannelData(0)

            if (wsRef.current && wsRef.current.readyState === WebSocket.OPEN) {
                wsRef.current.send(inputData.buffer)
            }
        }
    }

    const stopRecording = () => {
        setIsRecording(false)

        if (streamRef.current) {
            streamRef.current.getTracks().forEach(track => track.stop())
        }

        if (processorRef.current) {
            processorRef.current.disconnect()
        }

        if (audioContextRef.current) {
            audioContextRef.current.close()
        }

        if (wsRef.current) {
            wsRef.current.close()
        }
    }

    useEffect(() => {
        return () => {
            stopRecording()
        }
    }, [])

    return (
        <div className="bg-white rounded-lg shadow-lg p-8">
            <div className="text-center mb-6">
                <button
                    onClick={isRecording ? stopRecording : startRecording}
                    className={`relative inline-flex items-center justify-center w-20 h-20 rounded-full transition-all duration-300 ${isRecording
                        ? 'bg-red-500 hover:bg-red-600 animate-pulse-slow'
                        : 'bg-primary-500 hover:bg-primary-600'
                        }`}
                >
                    {isRecording ? (
                        <svg className="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <rect x="6" y="6" width="12" height="12" rx="2" />
                        </svg>
                    ) : (
                        <svg className="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M12 14c1.66 0 3-1.34 3-3V5c0-1.66-1.34-3-3-3S9 3.34 9 5v6c0 1.66 1.34 3 3 3z" />
                            <path d="M17 11c0 2.76-2.24 5-5 5s-5-2.24-5-5H5c0 3.53 2.61 6.43 6 6.92V21h2v-3.08c3.39-.49 6-3.39 6-6.92h-2z" />
                        </svg>
                    )}
                </button>
                <p className="mt-4 text-gray-600 font-medium">
                    {isRecording ? 'Enregistrement en cours...' : 'Cliquez pour démarrer'}
                </p>
            </div>

            {isRecording && (
                <div className="mb-4">
                    <div className="flex items-center justify-center gap-2 mb-2">
                        <div className="w-2 h-2 bg-red-500 rounded-full animate-pulse"></div>
                        <span className="text-sm text-red-500 font-medium">EN DIRECT</span>
                    </div>
                    {metrics && (
                        <div className="flex justify-center gap-4 text-xs text-gray-600">
                            <span className="bg-blue-100 px-2 py-1 rounded">
                                Vitesse: {metrics.speed}%
                            </span>
                            <span className="bg-green-100 px-2 py-1 rounded">
                                Confiance: {metrics.confidence}%
                            </span>
                            <span className="bg-yellow-100 px-2 py-1 rounded">
                                Latence: {metrics.latency}ms
                            </span>
                        </div>
                    )}
                </div>
            )}

            <div className="mt-6">
                <h3 className="text-lg font-semibold text-gray-900 mb-3">Transcription</h3>
                <div className="bg-gray-50 rounded-lg p-4 min-h-[200px] max-h-[400px] overflow-y-auto">
                    {transcription ? (
                        <p className="text-gray-800 leading-relaxed">{transcription}</p>
                    ) : (
                        <p className="text-gray-400 italic">La transcription apparaîtra ici...</p>
                    )}
                </div>
            </div>
        </div>
    )
}
