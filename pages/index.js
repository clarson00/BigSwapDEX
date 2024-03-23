import { useRouter } from "next/router"

export default function Home() {
    const router = useRouter()
    // Title
    // Description
    // button to go to the add liquidity page
    // button to go to swap page


    return (
        <>
            <main className="w-screen flex justify-center items-center">
                <div className="py-8 mx-32">
                <h1 className="text-white text-3xl font-bold">CCBIG DEX</h1>
                <h3 className="text-white text-xl font-black pt-12 ">
                    You must hold a CCBIG NFT to use the tools on this site. Site and tools are for CCBIG members only and
                    are for  demo and educational purposes only.
                    
                    A decentralized exchange (DEX) is a type of cryptocurrency exchange that operates without a central authority or
                    intermediaries. DEXs facilitate peer-to-peer trading of cryptocurrencies directly between users.
                </h3>
                <div className="py-6">
                    <button className="bg-pink-500 hover:bg-pink-600 text-white font-bold rounded px-8 py-2" onClick={async function(){
                        router.push('/swap')}}>
                        Swap
                    </button>
                    <button className="bg-pink-500 hover:bg-pink-600 text-white font-bold rounded px-8 py-2 ml-8" onClick={async function(){
                        router.push('/pools')}}>Liquidity</button>
                </div>

                </div>
            </main>
        </>
    )
}
