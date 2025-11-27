import { useState } from 'react'
import TabNavigation from './components/TabNavigation'
import LiveTranscription from './components/LiveTranscription'
import FileUpload from './components/FileUpload'

function App() {
    const [activeTab, setActiveTab] = useState('live')

    return (
        <div className="min-h-screen py-8 px-4">
            <div className="max-w-4xl mx-auto">
                {/* Header */}
                <div className="text-center mb-8">
                    <h1 className="text-4xl font-bold text-gray-900 mb-2">
                        🎙️ Transcription & Diarisation
                    </h1>
                    <p className="text-gray-600">
                        Transcription en temps réel et analyse de conversations
                    </p>
                </div>

                {/* Tabs */}
                <TabNavigation activeTab={activeTab} setActiveTab={setActiveTab} />

                {/* Content */}
                <div className="mt-6">
                    {activeTab === 'live' ? <LiveTranscription /> : <FileUpload />}
                </div>
            </div>
        </div>
    )
}

export default App
