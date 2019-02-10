//
//  MusicViewController.swift
//  MZK_iOS
//
//  Created by Ondrej Vyhlidal on 30/04/2018.
//  Copyright © 2018 Ondrej Vyhlidal. All rights reserved.
//

import UIKit
import AVFoundation

class MusicViewController: UIViewController {
    // shared instace for singleton purposes
    static let shared = MusicViewController()

    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var controllsContainer: UIView!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var progressBar: UISlider!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    @IBOutlet weak var tracklistContainerView: UIView!
    @IBOutlet weak var tracklistTableView: UITableView!
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var trackInfoButton: UIButton!

    var items: [MZKPageObject]?
    var currentItem: MZKItemResource?
    var allTracks: [MZKPageObject] = [MZKPageObject]()

    private var playlist = [AVPlayerItem]()
    private var queuePlayer = AVQueuePlayer()
    private var timer: Timer?
    private var currenItem: AVAsset?

    private var uiRefreshObserver: NSObject?
    private var lastTime = CMTime()
    private var numberOfTracks = 0

    lazy var datasource = MZKDatasource()

    private let startTime = "00:00"
    // we have to be able to play one song or whole album
    @objc var itemPID: String? {
        didSet {
           // datasource.siblings
            //GET http://localhost:8080/search/api/v5.0/item/<pid>/siblings
            datasource?.delegate = self
            datasource?.getItem(itemPID)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
        addObservers()
        addUIObserver()

        tracklistTableView.register(UINib(nibName: "MusicItemTableViewCell", bundle: nil), forCellReuseIdentifier: "MusicItemTableViewCell")
    }

    private func setupViews() {
        progressBar.minimumValue = 0
        progressBar.value = 0
        elapsedTimeLabel.text = startTime
        remainingTimeLabel.text = startTime
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func loadChildren() {
        guard let currentItemPID = currentItem?.pid else { return }
        datasource?.getChildrenForItem(currentItemPID)
    }

    private func loadChildren(forAsset pid: String) {
         datasource?.getChildrenForItem(pid)
    }

    private func loadSiblings() {
        guard let currentItemPID = currentItem?.pid else { return }
        datasource?.getSiblingsForItem(currentItemPID)
    }

    private func addUIObserver() {
        queuePlayer.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1), queue: nil) { [weak self](time) in
            guard let strongSelf = self else { return }

            strongSelf.updateUI(withCurrentTime: time)
        }
    }

    @objc private func updateUI(withCurrentTime time: CMTime) {
        // play pause button states
        if queuePlayer.rate != 0.0 {
            // playing
            playPauseButton.setImage(#imageLiteral(resourceName: "audioPause"), for: .normal)
        } else if queuePlayer.rate == 0 {
            // paused
            playPauseButton.setImage(#imageLiteral(resourceName: "audioPlay"), for: .normal)
        }

        // remaining time
        let seconds = CMTimeGetSeconds(queuePlayer.currentItem?.duration ?? .zero)
        let (hours, min, sec) = secondsToHoursMinutesSeconds(seconds: Int(seconds))

        if hours != 0 {
            remainingTimeLabel.text = String(format: "%02d:%02d:%02d", hours, min, sec)
        } else {
            remainingTimeLabel.text = String(format: "%02d:%02d", min, sec)
        }

        // elapsed time
        let elapsedSeconds = CMTimeGetSeconds(time)
        let (ehours, emin, esec) = secondsToHoursMinutesSeconds(seconds: Int(elapsedSeconds))

        if hours != 0 {
            elapsedTimeLabel.text = String(format: "%02d:%02d:%02d", ehours, emin, esec)
        } else {
            elapsedTimeLabel.text = String(format: "%02d:%02d", emin, esec)
        }

        // slider position
        progressBar.maximumValue = Float(seconds)
        progressBar.value = Float(elapsedSeconds)

    }

    func preparePlayerItems() {
        // URL for resurce
        // first version of player used this URL
        for item in allTracks {
            if let baseURL = (UIApplication.shared.delegate as? AppDelegate)?.defaultDatasourceItem.url {
                let finalStrURL = String(format: "%@/search/api/v5.0/item/%@/streams/MP3", baseURL, item.pid)
                if let url = URL(string: finalStrURL) {
                   // playlist.append(url)
                    let avAsset = AVAsset(url: url)
                    loadAVAsset(asset: avAsset) { [weak self](avAsset) in
                        guard let strongSelf = self else { return }
                        let playerItem = AVPlayerItem(asset: avAsset)
                        strongSelf.playlist.append(playerItem)
                        if strongSelf.queuePlayer.canInsert(playerItem, after: nil) {
                            strongSelf.queuePlayer.insert(playerItem, after: nil)
                        }
                    }
                }
            }
        }
    }

    private func loadAVAsset(asset: AVAsset, completion: @escaping (AVAsset) -> Void) {
        asset.loadValuesAsynchronously(forKeys: ["playable", "tracks", "duration"], completionHandler: {
            var error: NSError? = nil
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
            // Sucessfully loaded, continue processing
                DispatchQueue.main.async {
                    completion(asset)
                }
                break
            case .failed:
            // Examine NSError pointer to determine failure
                break
            case .cancelled:
            // Loading cancelled
                break
            default:
                // Handle all other cases
                break
            }
        })
    }

    private func playAsset(avAsset: AVAsset) {
        let session = AVAudioSession.sharedInstance()
        do {
            if #available(iOS 10.0, *) {
                try session.setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.moviePlayback, options: AVAudioSession.CategoryOptions.duckOthers)
            } else {
                // Fallback on earlier versions
            }
            // 1) Configure your audio session category, options, and mode
            // 2) Activate your audio session to enable your custom configuration
            try session.setActive(true)
        } catch let error as NSError {
            print("Unable to activate audio session:  \(error.localizedDescription)")
        }
    }

    func addObservers() {
        queuePlayer.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
    }

    func removeObservers() {

    }

    private func resetPlayback() {
        // reset UI, reset player
    }

    private func startPlayback() {
        // add observers, start playback
    }

    private func tracksLoaded() {
        preparePlayerItems()
    }

    private func playItemAtIndex(index: Int) {

        queuePlayer.removeAllItems()

        for tmpI in index...playlist.count-1 {
            let targetItem = playlist[tmpI]
            if queuePlayer.canInsert(targetItem, after: nil) {
                targetItem.seek(to: .zero)
                queuePlayer.insert(targetItem, after: nil)
            }
        }

        queuePlayer.play()
    }

    @IBAction func playPause(_ sender: Any) {
        if queuePlayer.rate == 0 {
            queuePlayer.play()
        } else {
            queuePlayer.pause()
        }
    }

    @IBAction func nextItem(_ sender: Any) {
        if let currentItem = queuePlayer.currentItem, let currentItemIndex = playlist.index(of: currentItem), currentItemIndex > 0 {
            let finalIndex = currentItemIndex + 1
            playItemAtIndex(index: finalIndex)
        }
    }

    @IBAction func previousItem(_ sender: Any) {
        if let currentItem = queuePlayer.currentItem, let currentItemIndex = playlist.index(of: currentItem), currentItemIndex > 0 {
            let finalIndex = currentItemIndex - 1
            playItemAtIndex(index: finalIndex)
        }
    }
}

extension MusicViewController {

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayerItem.status) {

            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }

            // Switch over status value
            switch status {
            case .readyToPlay:
                // Player item is ready to play.
                print("ready to play")
              //  queuePlayer.play()
                break
            case .failed:
                // Player item failed. See error.
                print("Failed")
                break
            case .unknown:
                // Player item is not yet ready.
                print("Unknown")
                break
            }
        }
    }
}

extension MusicViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        playItemAtIndex(index: indexPath.row)
    }
}

extension MusicViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicItemTableViewCell", for: indexPath) as! MusicItemTableViewCell
        cell.setup(withItem: allTracks[indexPath.row])
        return cell
    }
}

extension MusicViewController: DataLoadedDelegate {
    func detail(forItemLoaded item: MZKItemResource!) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            strongSelf.currentItem = item

            strongSelf.trackTitleLabel.text = item.rootTitle

            if item.model == .SoundUnit {
                strongSelf.loadChildren()
            } else if item.model == .SoundRecording {
                strongSelf.loadChildren()
            } else if item.model == .Track {
                // we have track item
                // strongSelf.allTracks.append(item)
            }
        }
    }

    func siblings(forItemLoaded results: [Any]!) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.items = results as? [MZKPageObject]
        }
    }

    func children(forItemLoaded items: [Any]!) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.items = items as? [MZKPageObject]

            for page in strongSelf.items as! [MZKPageObject] {
                if page.model == .SoundUnit {
                    strongSelf.numberOfTracks += 1
                    strongSelf.loadChildren(forAsset: page.pid)
                } else if page.model == .Track {
                    strongSelf.numberOfTracks -= 1
                    strongSelf.allTracks.append(page)
                    print("Append tracks")
                    if(strongSelf.numberOfTracks == 0) {
                        strongSelf.tracksLoaded()
                        strongSelf.tracklistTableView.reloadData()
                    }
                }
            }
        }
    }
}

extension MusicViewController {
    func secondsToHoursMinutesSeconds (seconds: Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
