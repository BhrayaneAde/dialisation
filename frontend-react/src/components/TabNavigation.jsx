export default function TabNavigation({ activeTab, setActiveTab }) {
    return (
        <div className="bg-white rounded-lg shadow-sm p-1 flex gap-1">
            <button
                onClick={() => setActiveTab('live')}
                className={`flex-1 py-3 px-6 rounded-md font-medium transition-all duration-200 ${activeTab === 'live'
                        ? 'bg-primary-500 text-white shadow-md'
                        : 'text-gray-600 hover:bg-gray-100'
                    }`}
            >
                <span className="flex items-center justify-center gap-2">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
                    </svg>
                    Mode Live
                </span>
            </button>
            <button
                onClick={() => setActiveTab('file')}
                className={`flex-1 py-3 px-6 rounded-md font-medium transition-all duration-200 ${activeTab === 'file'
                        ? 'bg-primary-500 text-white shadow-md'
                        : 'text-gray-600 hover:bg-gray-100'
                    }`}
            >
                <span className="flex items-center justify-center gap-2">
                    <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
                    </svg>
                    Mode Fichier (Diarisation)
                </span>
            </button>
        </div>
    )
}
