export default function DiarizationResults({ results }) {
    if (!results) {
        return (
            <div className="mt-6 text-center text-gray-500">
                Aucune parole détectée.
            </div>
        )
    }

    // Utiliser les segments depuis les résultats du backend FastAPI
    const segments = results.segments || []
    const speakers = results.speakers || {}

    if (segments.length === 0) {
        return (
            <div className="mt-6 text-center text-gray-500">
                Aucun segment détecté.
            </div>
        )
    }

    // Identifier les locuteurs uniques
    const uniqueSpeakers = Object.keys(speakers)
    
    const speakerColors = {
        'ORATEUR_PRINCIPAL': 'bg-blue-100 border-blue-300 text-blue-900',
        'SPEAKER_00': 'bg-purple-100 border-purple-300 text-purple-900',
        'SPEAKER_01': 'bg-orange-100 border-orange-300 text-orange-900',
        'SPEAKER_02': 'bg-pink-100 border-pink-300 text-pink-900',
        'SPEAKER_03': 'bg-green-100 border-green-300 text-green-900',
    }

    const speakerMap = {}
    uniqueSpeakers.forEach((spk) => {
        speakerMap[spk] = speakerColors[spk] || 'bg-gray-100 border-gray-300 text-gray-900'
    })

    return (
        <div className="mt-6">
            <div className="flex items-center justify-between mb-4">
                <h3 className="text-lg font-semibold text-gray-900">
                    📝 Résultats de la diarisation ({uniqueSpeakers.length} locuteur{uniqueSpeakers.length > 1 ? 's' : ''})
                </h3>
            </div>

            {/* Résumé par locuteur */}
            <div className="mb-6 grid grid-cols-1 md:grid-cols-2 gap-4">
                {uniqueSpeakers.map((speaker) => (
                    <div
                        key={speaker}
                        className={`p-4 rounded-lg border-l-4 ${speakerMap[speaker]}`}
                    >
                        <div className="font-semibold text-sm mb-2">🎤 {speaker}</div>
                        <div className="text-xs space-y-1">
                            <p>⏱️ Durée: <span className="font-mono">{speakers[speaker].duration}</span></p>
                            <p>📊 Segments: <span className="font-semibold">{speakers[speaker].segments.length}</span></p>
                        </div>
                    </div>
                ))}
            </div>

            {/* Conversation détaillée */}
            <div>
                <h4 className="text-sm font-semibold text-gray-700 mb-3">💬 Conversation détaillée</h4>
                <div className="space-y-3 max-h-[500px] overflow-y-auto bg-gray-50 p-4 rounded-lg">
                    {segments.map((segment, index) => (
                        <div
                            key={index}
                            className={`p-4 rounded-lg border-l-4 ${speakerMap[segment.speaker] || 'bg-gray-100 border-gray-300'}`}
                        >
                            <div className="flex items-center justify-between mb-2">
                                <span className="font-semibold text-sm">{segment.speaker}</span>
                                <span className="text-xs text-gray-500 font-mono">
                                    {segment.start} - {segment.end}
                                </span>
                            </div>
                            <p className="text-gray-800 text-sm">{segment.text}</p>
                        </div>
                    ))}
                </div>
            </div>

            {/* Transcript complet */}
            {results.full_transcript && (
                <div className="mt-6">
                    <h4 className="text-sm font-semibold text-gray-700 mb-3">📄 Transcript complet</h4>
                    <textarea
                        value={results.full_transcript}
                        readOnly
                        className="w-full h-40 p-4 border rounded-lg bg-gray-50 text-sm font-mono"
                    />
                </div>
            )}
        </div>
    )
}
